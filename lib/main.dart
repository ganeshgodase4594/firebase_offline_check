// lib/main.dart
import 'package:brainmoto_app/firebase_options.dart';
import 'package:brainmoto_app/screens/super-admin/super_admin_dashboard.dart';
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:brainmoto_app/service/offline_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/app_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/coordinator/coordinator_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase offline settings
    await FirebaseService.initializeOfflineSettings();

    // Start auto sync
    await OfflineService.startAutoSync();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const BrainmotoApp());
}

class BrainmotoApp extends StatelessWidget {
  const BrainmotoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Brainmoto MSAP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF4e3f8a),
          scaffoldBackgroundColor: const Color(0xFFf2efff),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4e3f8a),
            secondary: const Color(0xFFf5d527),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4e3f8a),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4e3f8a),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/teacher-dashboard': (context) => const TeacherDashboardV2(),
          '/coordinator-dashboard': (context) => const CoordinatorDashboard(),
          '/super-admin-dashboard': (context) => const SuperAdminDashboard(),
        },
      ),
    );
  }
}
