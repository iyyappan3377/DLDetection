import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// ignore: implementation_imports
import 'package:face_verification/src/services/tflite_embedder.dart';
// ignore: implementation_imports
import 'package:face_verification/src/utils/preprocess.dart';
// ignore: implementation_imports
import 'package:face_verification/src/services/verification.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Result models ──────────────────────────────────────────────────────────

class DrivingLicenseValidationResult {
  final bool isDrivingLicense;
  final Rect? faceBoundingBox;
  final String extractedText;
  final int confidenceScore;

  const DrivingLicenseValidationResult({
    required this.isDrivingLicense,
    required this.faceBoundingBox,
    required this.extractedText,
    required this.confidenceScore,
  });
}

class IdentityVerificationResult {
  final bool isDrivingLicense;
  final Rect? licenseFace;
  final Rect? selfieFace;
  final double similarityScore;
  final bool verified;
  final String extractedText;
  final int confidenceScore;

  const IdentityVerificationResult({
    required this.isDrivingLicense,
    required this.licenseFace,
    required this.selfieFace,
    required this.similarityScore,
    required this.verified,
    required this.extractedText,
    required this.confidenceScore,
  });
}

// ─── LivenessScreen ──────────────────────────────────────────────────────────

class LivenessScreen extends StatefulWidget {
  final String? licenseImagePath;
  final Rect? licenseFaceBoundingBox;
  final String? extractedText;

  const LivenessScreen({
    super.key,
    this.licenseImagePath,
    this.licenseFaceBoundingBox,
    this.extractedText,
  });

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  TfliteEmbedder? _embedder;
  bool _isEmbedderReady = false;

  int _currentStepIndex = 0;
  bool _isCameraReady = false;
  bool _isBusy = false;
  bool _didNavigate = false;
  bool _stepCompleted = false;
  String _statusMessage = '';

  DrivingLicenseValidationResult? _licenseValidationResult;
  String? _licenseImagePath;

  int _consecutiveValidFrames = 0;
  static const int _requiredFrames = 8;

  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const List<String> _indiaStateKeywords = [
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

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.licenseImagePath != null) {
      _licenseImagePath = widget.licenseImagePath;
      _licenseValidationResult = DrivingLicenseValidationResult(
        isDrivingLicense: true,
        faceBoundingBox: widget.licenseFaceBoundingBox,
        extractedText: widget.extractedText ?? '',
        confidenceScore: 0,
      );
      _statusMessage = 'Starting live selfie verification…';
      unawaited(_initCamera());
    } else {
      _statusMessage = 'No license provided';
    }
  }

  @override
  void dispose() {
    _tearDownCamera();
    _embedder?.close();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Camera lifecycle ────────────────────────────────────────────────────────

  void _tearDownCamera() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _faceDetector?.close();
    _faceDetector = null;
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _statusMessage = 'Camera permission denied');
      return;
    }

    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    _cameraController = CameraController(
      front,
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
  }

  // ── Frame processing ────────────────────────────────────────────────────────

  Future<void> _onFrame(CameraImage image) async {
    if (_isBusy || _didNavigate) return;
    if (_currentStepIndex >= LivenessStepInfo.steps.length) return;
    if (_faceDetector == null) return;

    _isBusy = true;
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        _consecutiveValidFrames = 0;
        if (mounted) setState(() => _statusMessage = 'No face detected');
        return;
      }

      final eulerY = faces.first.headEulerAngleY ?? 0.0;
      final step = LivenessStepInfo.steps[_currentStepIndex];
      bool isValid = false;

      switch (step.step) {
        case LivenessStep.lookLeft:
          isValid = eulerY > 18.0;
          if (mounted) setState(() => _statusMessage = 'Move head LEFT');
          break;
        case LivenessStep.lookRight:
          isValid = eulerY < -18.0;
          if (mounted) setState(() => _statusMessage = 'Move head RIGHT');
          break;
        case LivenessStep.lookStraight:
          isValid = eulerY.abs() < 10.0;
          if (mounted) setState(() => _statusMessage = isValid ? 'Hold still…' : 'Look straight');
          break;
        default:
          break;
      }

      if (isValid) {
        _consecutiveValidFrames++;
        _progressController.animateTo(_consecutiveValidFrames / _requiredFrames);
        if (_consecutiveValidFrames >= _requiredFrames) {
          _consecutiveValidFrames = 0;
          _isBusy = false; // release before await
          await _advanceStep();
          return;
        }
      } else {
        if (_consecutiveValidFrames > 0) {
          _consecutiveValidFrames = 0;
          _progressController.animateTo(0);
        }
      }
    } catch (e) {
      debugPrint('Liveness frame error: $e');
    } finally {
      if (!_didNavigate) _isBusy = false;
    }
  }

  // ── Step advancement ────────────────────────────────────────────────────────

  Future<void> _advanceStep() async {
    if (_currentStepIndex >= LivenessStepInfo.steps.length || _didNavigate) return;

    final step = LivenessStepInfo.steps[_currentStepIndex];

    if (mounted) {
      setState(() {
        _stepCompleted = true;
        _statusMessage = step.completedText;
      });
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (_didNavigate || !mounted) return;

    if (step.step == LivenessStep.lookStraight) {
      await _captureSelfie();
    } else {
      if (mounted) {
        setState(() {
          _currentStepIndex++;
          _stepCompleted = false;
          _progressController.reset();
        });
      }
    }
  }

  // ── Selfie capture ──────────────────────────────────────────────────────────

  Future<void> _captureSelfie() async {
    if (_didNavigate) return;

    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      if (mounted) setState(() => _statusMessage = 'Capturing selfie…');

      final XFile photo = await _cameraController!.takePicture();
      final savedPath = photo.path;

      if (mounted) setState(() => _statusMessage = 'Matching face…');

      final result = await _verifyIdentityFromImages(_licenseImagePath!, savedPath);

      if (_didNavigate || !mounted) return;

      // ── THE FIX (same pattern as DrivingLicenseCaptureScreen) ─────────────
      // Grab navigator before any dispose/async so context stays valid.
      final navigator = Navigator.of(context);
      _didNavigate = true;
      _tearDownCamera();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => SelfieResultScreen(
              imagePath: savedPath,
              licenseImagePath: _licenseImagePath,
              verificationResult: result,
            ),
          ),
        );
      });
      // ──────────────────────────────────────────────────────────────────────

    } catch (e) {
      debugPrint('Selfie capture error: $e');
      if (!_didNavigate) {
        try {
          await _cameraController?.startImageStream(_onFrame);
        } catch (_) {}
      }
    }
  }

  // ── Face verification ───────────────────────────────────────────────────────

  Future<void> _ensureEmbedderReady() async {
    if (_isEmbedderReady) return;
    _embedder ??= TfliteEmbedder(
      modelAsset: 'packages/face_verification/assets/models/facenet.tflite',
    );
    await _embedder!.loadModel();
    _isEmbedderReady = true;
  }

  bool _matchesDlNumberPattern(String t) {
    final c = t.replaceAll(RegExp(r'[^A-Z0-9]+'), ' ');
    return [
      RegExp(r'\b[A-Z]{2}\s?\d{1,2}\s?\d{4}\s?\d{4,8}\b'),
      RegExp(r'\b[A-Z]{2}\s?\d{1,2}\s?\d{4}\s?[A-Z0-9]{4,8}\b'),
      RegExp(r'\b[A-Z]{2}\s?\d{2}\s?\d{4}\s?\d{7,8}\b'),
    ].any((p) => p.hasMatch(c));
  }

  Future<DrivingLicenseValidationResult> _validateDrivingLicenseImage(
      String imagePath) async {
    final tr = TextRecognizer(script: TextRecognitionScript.latin);
    final fd = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false, enableLandmarks: false,
        enableContours: false, enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    try {
      final img = InputImage.fromFilePath(imagePath);
      final text = await tr.processImage(img);
      final n = text.text.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      final s = <String>{};
      if (n.contains('DRIVING') || n.contains('DRIV')) s.add('driving');
      if (n.contains('LICENCE') || n.contains('LICENSE') || n.contains('LICEN')) s.add('license');
      if (RegExp(r'\bDL\b').hasMatch(n) || n.contains('DL NO') || n.contains('DLNO')) s.add('dl_prefix');
      if (_matchesDlNumberPattern(n)) s.add('dl_number');
      if (n.contains('INDIA') || RegExp(r'\bIND\b').hasMatch(n)) s.add('india');
      if (_indiaStateKeywords.any(n.contains)) s.add('state');
      if (s.length < 2) {
        return DrivingLicenseValidationResult(
            isDrivingLicense: false, faceBoundingBox: null,
            extractedText: text.text, confidenceScore: s.length);
      }
      final faces = await fd.processImage(img);
      final bbox = faces.isNotEmpty ? faces.first.boundingBox : null;
      return DrivingLicenseValidationResult(
          isDrivingLicense: bbox != null, faceBoundingBox: bbox,
          extractedText: text.text, confidenceScore: s.length);
    } finally {
      await tr.close();
      await fd.close();
    }
  }

  Future<List<Face>> _detectFaces(String imagePath) async {
    final fd = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false, enableLandmarks: false,
        enableContours: false, enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    try {
      return await fd.processImage(InputImage.fromFilePath(imagePath));
    } finally {
      await fd.close();
    }
  }

  Future<double> _calculateSimilarity(String licPath, String selfiePath) async {
    await _ensureEmbedderReady();
    final licBytes = await File(licPath).readAsBytes();
    final selfieBytes = await File(selfiePath).readAsBytes();
    final licFaces = await _detectFaces(licPath);
    final selfieFaces = await _detectFaces(selfiePath);
    if (licFaces.isEmpty || selfieFaces.isEmpty) return 0.0;
    final licInput = await preprocessForModel(
      rawImageBytes: licBytes, face: licFaces.first,
      inputSize: _embedder!.getModelInputSize(),
    );
    final selfieInput = await preprocessForModel(
      rawImageBytes: selfieBytes, face: selfieFaces.first,
      inputSize: _embedder!.getModelInputSize(),
    );
    final licEmb = await _embedder!.runModelOnPreprocessed(licInput);
    final selfieEmb = await _embedder!.runModelOnPreprocessed(selfieInput);
    return (((cosineSimilarity(licEmb, selfieEmb) + 1.0) / 2.0) * 100.0)
        .clamp(0.0, 100.0);
  }

  Future<IdentityVerificationResult> _verifyIdentityFromImages(
      String licPath, String selfiePath) async {
    final licVal = _licenseValidationResult ??
        await _validateDrivingLicenseImage(licPath);
    final licenseFace = licVal.faceBoundingBox;
    if (!licVal.isDrivingLicense || licenseFace == null) {
      return IdentityVerificationResult(
          isDrivingLicense: false, licenseFace: licenseFace, selfieFace: null,
          similarityScore: 0.0, verified: false,
          extractedText: licVal.extractedText, confidenceScore: licVal.confidenceScore);
    }
    final selfieFaces = await _detectFaces(selfiePath);
    final selfieFace = selfieFaces.isNotEmpty ? selfieFaces.first.boundingBox : null;
    if (selfieFace == null) {
      return IdentityVerificationResult(
          isDrivingLicense: true, licenseFace: licenseFace, selfieFace: null,
          similarityScore: 0.0, verified: false,
          extractedText: licVal.extractedText, confidenceScore: licVal.confidenceScore);
    }
    final score = await _calculateSimilarity(licPath, selfiePath);
    return IdentityVerificationResult(
        isDrivingLicense: true, licenseFace: licenseFace, selfieFace: selfieFace,
        similarityScore: score, verified: score > 70.0,
        extractedText: licVal.extractedText, confidenceScore: licVal.confidenceScore);
  }

  // ── Input image builder ─────────────────────────────────────────────────────

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
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

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.licenseImagePath == null) return _buildNoLicenseView();
    if (!_isCameraReady) return _buildLoadingView();
    return _buildCameraView();
  }

  Widget _buildNoLicenseView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.badge_outlined, size: 64, color: Color(0xFF1A73E8)),
                const SizedBox(height: 16),
                const Text('No License Provided',
                    style: TextStyle(color: Colors.white, fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(_statusMessage, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1A73E8)),
            const SizedBox(height: 16),
            Text(_statusMessage.isEmpty ? 'Initializing camera…' : _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    final stepIndex = _currentStepIndex.clamp(0, LivenessStepInfo.steps.length - 1);
    final stepInfo = LivenessStepInfo.steps[stepIndex];
    final isDone = _currentStepIndex >= LivenessStepInfo.steps.length;

    final controller = _cameraController!;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(scale: scale,
              child: Center(child: CameraPreview(controller))),
          Container(color: Colors.black.withValues(alpha: 0.35)),
          _buildOvalGuide(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0, right: 0,
            child: _buildStepIndicators(),
          ),
          if (!isDone)
            Positioned(bottom: 100, left: 24, right: 24,
                child: _buildInstructionCard(stepInfo)),
          if (!isDone)
            Positioned(bottom: 72, left: 48, right: 48,
                child: _buildProgressBar()),
          Positioned(
            bottom: 36, left: 0, right: 0,
            child: Text(_statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _stepCompleted ? Colors.greenAccent : Colors.white70,
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildOvalGuide() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, __) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 220, height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(110),
              border: Border.all(
                color: _stepCompleted ? Colors.greenAccent : const Color(0xFF1A73E8),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_stepCompleted ? Colors.greenAccent : const Color(0xFF1A73E8))
                      .withValues(alpha: 0.3),
                  blurRadius: 20, spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(LivenessStepInfo.steps.length, (i) {
        final done = i < _currentStepIndex;
        final current = i == _currentStepIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: current ? 32 : 10, height: 10,
          decoration: BoxDecoration(
            color: done ? Colors.greenAccent
                : current ? const Color(0xFF1A73E8) : Colors.white24,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildInstructionCard(LivenessStepInfo stepInfo) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(stepInfo.step),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Text(stepInfo.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_currentStepIndex + 1} of ${LivenessStepInfo.steps.length}',
                    style: const TextStyle(color: Color(0xFF1A73E8),
                        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(stepInfo.instruction,
                      style: const TextStyle(color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w700, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: _progressController.value,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(
              _stepCompleted ? Colors.greenAccent : const Color(0xFF1A73E8)),
          minHeight: 6,
        ),
      ),
    );
  }
}

// ─── SelfieResultScreen ──────────────────────────────────────────────────────

class SelfieResultScreen extends StatelessWidget {
  final String imagePath;
  final String? licenseImagePath;
  final IdentityVerificationResult verificationResult;

  const SelfieResultScreen({
    super.key,
    required this.imagePath,
    required this.verificationResult,
    this.licenseImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final ok = verificationResult.verified;
    final color = ok ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(ok ? Icons.verified_rounded : Icons.error_outline_rounded,
                  color: color, size: 56),
              const SizedBox(height: 12),
              Text(ok ? 'User Verified ✓' : 'Face Does Not Match',
                  style: const TextStyle(color: Colors.white, fontSize: 24,
                      fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(
                ok ? 'The selfie matches the uploaded Driving License.'
                    : 'The selfie does not match the uploaded Driving License.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Previews
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: licenseImagePath != null
                    ? Row(children: [
                        Expanded(child: _PreviewCard(label: 'License', imagePath: licenseImagePath!)),
                        const SizedBox(width: 12),
                        Expanded(child: _PreviewCard(label: 'Selfie', imagePath: imagePath)),
                      ])
                    : _PreviewCard(label: 'Selfie', imagePath: imagePath),
              ),
              const SizedBox(height: 20),

              // Debug info
              _InfoCard(children: [
                _row('isDrivingLicense', '${verificationResult.isDrivingLicense}'),
                _row('licenseFace', '${verificationResult.licenseFace}'),
                _row('selfieFace', '${verificationResult.selfieFace}'),
                _row('similarityScore', '${verificationResult.similarityScore.toStringAsFixed(1)}%'),
                _row('confidenceScore', '${verificationResult.confidenceScore}'),
                const SizedBox(height: 6),
                SelectableText(verificationResult.extractedText,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
              const SizedBox(height: 18),

              _InfoCard(children: [
                SelectableText(imagePath,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _btn(
                      label: 'Use This Photo',
                      color: const Color(0xFF1A73E8),
                      textColor: Colors.white,
                      onTap: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Selfie saved!'))),
                    ),
                    const SizedBox(height: 12),
                    _outlineBtn(
                      label: 'Retake',
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LivenessScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'This verification confirms that the selfie matches the uploaded Driving License. This is not government validation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('$label: $value',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      );

  Widget _btn({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      );

  Widget _outlineBtn({required String label, required VoidCallback onTap}) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final String label;
  final String imagePath;
  const _PreviewCard({required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          ),
        ],
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      );
}

// ─── Liveness step definitions ───────────────────────────────────────────────

enum LivenessStep { lookLeft, lookRight, lookStraight, completed }

class LivenessStepInfo {
  final LivenessStep step;
  final String instruction;
  final String emoji;
  final String completedText;

  const LivenessStepInfo({
    required this.step,
    required this.instruction,
    required this.emoji,
    required this.completedText,
  });

  static const List<LivenessStepInfo> steps = [
    LivenessStepInfo(
      step: LivenessStep.lookLeft,
      instruction: 'Turn your head\nto the LEFT',
      emoji: '👈',
      completedText: 'Great! Left side complete ✓',
    ),
    LivenessStepInfo(
      step: LivenessStep.lookRight,
      instruction: 'Turn your head\nto the RIGHT',
      emoji: '👉',
      completedText: 'Great! Right side complete ✓',
    ),
    LivenessStepInfo(
      step: LivenessStep.lookStraight,
      instruction: 'Look STRAIGHT\nat the camera',
      emoji: '😐',
      completedText: 'Perfect! Taking selfie…',
    ),
  ];
}