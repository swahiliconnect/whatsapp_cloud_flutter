import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  runApp(const MyApp());
}

/// Main application widget for the example app.
class MyApp extends StatelessWidget {
  /// Creates a new MyApp instance.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Cloud API Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}