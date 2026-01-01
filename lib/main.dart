import 'dart:io';

import 'package:flutter/material.dart';
import 'package:property/screens/splash_screen.dart';
import 'package:property/network/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize GetIt
  await setupServiceLocator();

  // ❌ DO NOT manually set WebViewPlatform anymore
  // webview_flutter auto-initializes on Android & iOS

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
