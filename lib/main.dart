import 'package:batch_printing_manager/printing.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Print PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PrintPDFScreen(),
      debugShowCheckedModeBanner: false,
    );
    
  }
}
