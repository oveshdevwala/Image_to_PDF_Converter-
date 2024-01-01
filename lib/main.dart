import 'package:flutter/material.dart';
import 'package:image_to_pdf_converter/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PdfHomeScreen(),
      title: "PDF Converter",
    );
  }
}
