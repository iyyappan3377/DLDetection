import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'camera.dart';

class DrivingLicenseVerificationResult {
  final bool licenseDetected;
  final Rect? licenseFaceBoundingBox;
  final String licenseImagePath;
  final String extractedText;
  final bool readyForSelfie;

  const DrivingLicenseVerificationResult({
    required this.licenseDetected,
    required this.licenseFaceBoundingBox,
    required this.licenseImagePath,
    required this.extractedText,
    required this.readyForSelfie,
  });
}

class DrivingLicenseCaptureScreen extends StatefulWidget {
  const DrivingLicenseCaptureScreen({super.key});

  @override
  State<DrivingLicenseCaptureScreen> createState() =>
      _DrivingLicenseCaptureScreenState();
}

class _DrivingLicenseCaptureScreenState
    extends State<DrivingLicenseCaptureScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  TextRecognizer? _textRecognizer;

  bool _isInitializing = false;
  bool _isCameraReady = false;
  bool _isBusy = false;
  bool _didNavigate = false;

  String _statusMessage = 'Place your Driving License inside the frame';

  static const List<String> _indiaStateKeywords = <String>[
    'ANDHRA PRADESH', 'ARUNACHAL PRADESH', 'ASSAM', 'BIHAR', 'CHHATTISGARH',
    'GOA', 'GUJARAT', 'HARYANA', 'HIMACHAL PRADESH', 'JHARKHAND', 'KARNATAKA',
    'KERALA', 'MADHYA PRADESH', 'MAHARASHTRA', 'MANIPUR', 'MEGHALAYA',
    'MIZORAM', 'NAGALAND', 'ODISHA', 'PUNJAB', 'RAJASTHAN', 'SIKKIM',
    'TAMIL NADU', 'TELANGANA', 'TRIPURA', 'UTTAR PRADESH', 'UTTARAKHAND',
    'WEST BENGAL',
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_initializeCamera());
  }

  @override
  void dispose() {
    _tearDownCamera();
    super.dispose();
  }

  // ── Camera lifecycle ──────────────────────────────────────────────────────

  void _tearDownCamera() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _faceDetector?.close();
    _faceDetector = null;
    _textRecognizer?.close();
    _textRecognizer = null;
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing || _didNavigate) return;
    _isInitializing = true;

    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) setState(() => _statusMessage = 'Camera permission denied');
        return;
      }

      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: false,
          enableLandmarks: false,
          enableContours: false,
          enableTracking: false,
          minFaceSize: 0.05,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      _cameraController = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (!mounted || _didNavigate) return;

      setState(() => _isCameraReady = true);
      await _cameraController!.startImageStream(_onFrame);
    } catch (e) {
      debugPrint('DL cam init error: $e');
      if (mounted) setState(() => _statusMessage = 'Failed to start camera');
    } finally {
      _isInitializing = false;
    }
  }

  // ── Frame callback ────────────────────────────────────────────────────────

  Future<void> _onFrame(CameraImage image) async {
    if (_isBusy || _didNavigate) return;
    if (_textRecognizer == null || _cameraController == null) return;

    _isBusy = true;
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;

      final result = await _textRecognizer!.processImage(inputImage);
      final normalized =
          result.text.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();

      if (_scoreDrivingLicense(normalized) < 2) {
        if (mounted &&
            _statusMessage != 'Place your Driving License inside the frame') {
          setState(
              () => _statusMessage = 'Place your Driving License inside the frame');
        }
        return;
      }

      if (mounted) setState(() => _statusMessage = 'License detected — capturing…');
      await _captureAndProceed();
    } catch (e) {
      debugPrint('Frame OCR error: $e');
    } finally {
      if (!_didNavigate) _isBusy = false;
    }
  }

  // ── Capture & validate ────────────────────────────────────────────────────

  Future<void> _captureAndProceed() async {
    // Stop stream before takePicture
    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 250));

    try {
      final XFile photo = await _cameraController!.takePicture();
      final savedPath = photo.path;

      final extraction = await _validateCapture(savedPath);

      if (!mounted || _didNavigate) return;

      if (!extraction.readyForSelfie) {
        setState(
            () => _statusMessage = 'Please show a clear DL with a visible face');
        await Future.delayed(const Duration(milliseconds: 800));
        // Retry: restart stream
        try {
          await _cameraController?.startImageStream(_onFrame);
        } catch (_) {
          _tearDownCamera();
          _isCameraReady = false;
          _isBusy = false;
          unawaited(_initializeCamera());
        }
        return;
      }

      // Show success message
      if (mounted) {
        setState(
            () => _statusMessage = 'Driving License verified ✓  Moving to selfie…');
      }

      // ── THE FIX ────────────────────────────────────────────────────────────
      // Capture the navigator reference NOW while context is still fully mounted
      // and attached — BEFORE we dispose the camera or do any further async work.
      final navigator = Navigator.of(context);

      // Block all further frame processing immediately.
      _didNavigate = true;

      // Tear down camera (synchronous; does not await so context stays valid).
      _tearDownCamera();

      // Schedule the push on the next frame so the widget tree has finished
      // its current build/setState cycle. This is the exact fix for the
      // "verified message shows but screen never changes" bug.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => LivenessScreen(
              licenseImagePath: extraction.licenseImagePath,
              licenseFaceBoundingBox: extraction.licenseFaceBoundingBox,
              extractedText: extraction.extractedText,
            ),
          ),
        );
      });
      // ──────────────────────────────────────────────────────────────────────

    } catch (e) {
      debugPrint('Capture error: $e');
      if (!_didNavigate) {
        try {
          await _cameraController?.startImageStream(_onFrame);
        } catch (_) {
          _tearDownCamera();
          _isCameraReady = false;
          _isBusy = false;
          unawaited(_initializeCamera());
        }
      }
    }
  }

  Future<DrivingLicenseVerificationResult> _validateCapture(
      String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final text = await _textRecognizer!.processImage(inputImage);
    final normalized =
        text.text.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final score = _scoreDrivingLicense(normalized);
    final faces = await _faceDetector!.processImage(inputImage);
    final bbox = faces.isNotEmpty ? faces.first.boundingBox : null;

    return DrivingLicenseVerificationResult(
      licenseDetected: score >= 2 && bbox != null,
      licenseFaceBoundingBox: bbox,
      licenseImagePath: imagePath,
      extractedText: text.text,
      readyForSelfie: bbox != null,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _scoreDrivingLicense(String t) {
    final s = <String>{};
    if (t.contains('DRIVING') || t.contains('DRIV')) s.add('driving');
    if (t.contains('LICENCE') || t.contains('LICENSE') || t.contains('LICEN'))
      s.add('license');
    if (RegExp(r'\bDL\b').hasMatch(t) ||
        t.contains('DL NO') ||
        t.contains('DLNO')) s.add('dl');
    if (t.contains('INDIA') || RegExp(r'\bIND\b').hasMatch(t)) s.add('india');
    if (_indiaStateKeywords.any(t.contains)) s.add('state');
    return s.length;
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null || image.planes.isEmpty) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraReady ? _buildCameraView() : _buildLoadingView(),
    );
  }

  Widget _buildLoadingView() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1A73E8)),
            const SizedBox(height: 16),
            Text(_statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    final controller = _cameraController!;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(controller)),
        ),
        Container(color: Colors.black.withValues(alpha: 0.35)),
        _buildFrame(),
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 24,
          right: 24,
          child: const Text(
            'Place your Driving License inside the frame',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 24,
          right: 24,
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildFrame() {
    return Center(
      child: Container(
        width: 320,
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1A73E8), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}