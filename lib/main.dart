

import 'package:dldetection/userBookings.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}
class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
      home:userBookings()
      
    );
  }
}
