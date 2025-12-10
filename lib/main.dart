// lib/main.dart - UPDATED with ALL providers
import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/firebase_options.dart';
import 'package:brainmoto_app/providers/coordinator_provider.dart';
import 'package:brainmoto_app/router/app_router.dart';
import 'package:brainmoto_app/screens/coordinator/school_detail_screen.dart';
import 'package:brainmoto_app/screens/super-admin/super_admin_dashboard.dart';
import 'package:brainmoto_app/screens/teacher/assessment_question_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/assessment_type_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/bottom_navigationbar_figma.dart';
import 'package:brainmoto_app/screens/teacher/student_list_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/assessment_workflow_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/teacher_dashboard.dart';
import 'package:brainmoto_app/screens/teacher/teacher_dashboard_screen_figma.dart';
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:brainmoto_app/service/offline_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// ALL Providers
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/app_provider.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/school_provider.dart';
import 'providers/question_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
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
          // Core providers
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ChangeNotifierProvider(create: (_) => AppProvider()),

          // Feature providers (available globally)
          ChangeNotifierProvider(create: (_) => SchoolProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => TeacherProvider()),
          ChangeNotifierProvider(create: (_) => QuestionProvider()),
          ChangeNotifierProvider(
              create: (_) => CoordinatorProvider()..loadSchools())

          // Assessment provider created locally in assessment screens
        ],
        child: MaterialApp.router(
          title: 'Brainmoto MSAP',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.appBarBackColor.withValues(alpha: .9),
              elevation: 0,
            ),
          ),
          routerConfig: appRouter,
        ));
  }
}
