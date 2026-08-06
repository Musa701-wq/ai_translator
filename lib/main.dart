/*
// lib/main.dart
import 'package:aitranlator/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ads/ad_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdProvider()),
        // ... other providers
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}*//*

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ads/ad_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdProvider()),
        // ... other providers
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}*/
// lib/main.dart
/*
import 'package:aitranlator/providers/auth_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ads/ad_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ... other providers
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}*/
import 'dart:io';  // ⬅️ YE ADD KARO TOP PE
import 'package:aitranlator/providers/auth_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'ads/ad_provider.dart';
import 'in_app_purchase/credit_manager.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔍 DEBUG CODE - ADD THIS
  if (Platform.isIOS) {
    debugPrint("\n╔════════════════════════════════════════╗");
    debugPrint("║  🔍 PERMISSION CHECK AT STARTUP        ║");
    debugPrint("╚════════════════════════════════════════╝");

    var mic = await Permission.microphone.status;
    var speech = await Permission.speech.status;

    debugPrint("🎤 Microphone: $mic");
    debugPrint("   isGranted: ${mic.isGranted}");
    debugPrint("   isDenied: ${mic.isDenied}");
    debugPrint("   isPermanentlyDenied: ${mic.isPermanentlyDenied}");

    debugPrint("🗣️ Speech: $speech");
    debugPrint("   isGranted: ${speech.isGranted}");
    debugPrint("   isDenied: ${speech.isDenied}");
    debugPrint("   isPermanentlyDenied: ${speech.isPermanentlyDenied}");
    debugPrint("════════════════════════════════════════\n");
  }

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CreditManager(),
        ),
        ChangeNotifierProxyProvider<CreditManager, AdProvider>(
          create: (context) => AdProvider(
            creditManager: context.read<CreditManager>(),
          ),
          update: (context, creditManager, previous) =>
          previous ?? AdProvider(creditManager: creditManager),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}