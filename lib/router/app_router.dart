// lib/router/app_router.dart
import 'package:brainmoto_app/screens/coordinator/coordinator_dashboard.dart';
import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/coordinator/school_detail_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/coordinator-dashboard',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/coordinator-dashboard',
        builder: (context, state) => const CoordinatorDashboardRefactored(),
      ),
      GoRoute(
        path: '/school-detail',
        builder: (context, state) => const SchoolDetailScreenRefactored(),
      ),
    ],
  );
}
