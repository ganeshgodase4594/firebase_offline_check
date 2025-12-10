import 'package:brainmoto_app/screens/teacher/assessment_type_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/assessment_workflow_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/bottom_navigationbar_figma.dart';
import 'package:brainmoto_app/screens/teacher/profile_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/student_list_screen_figma.dart';
import 'package:go_router/go_router.dart';
import 'package:brainmoto_app/screens/teacher/teacher_dashboard_screen_figma.dart';
import 'package:brainmoto_app/screens/teacher/assessment_question_screen_figma.dart';
import 'package:brainmoto_app/screens/login_screen.dart';

//  {
//           '/login': (context) => const LoginScreen(),
//           '/teacher-dashboard': (context) => const TeacherDashboardScreen(),
//           '/student-list': (context) => StudentListScreenFigma(),
//           '/assessment-workflow': (context) => AssessmentWorkflowScreenFigma(),
//           '/assessment-type': (context) => ChooseAssessmentTypeScreen(),
//           '/question-screen': (context) => AssessmentQuestionScreen(
//               studentName: "Ganesh Godase", studentId: "ABC1", level: 1),
//           '/coordinator-dashboard': (context) =>
//               const CoordinatorDashboardRefactored(),
//           '/super-admin-dashboard': (context) => const SuperAdminDashboard(),
//           '/school-detail': (context) => const SchoolDetailScreenRefactored()
//         },

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    /// ----------------- LOGIN (No Bottom Nav) -----------------
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// ----------------- SHELL WITH BOTTOM NAV -----------------
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(shellChild: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const TeacherDashboardScreen(),
        ),
        GoRoute(
          path: '/assessment-question',
          builder: (context, state) => const AssessmentQuestionScreen(
            studentName: "Ganesh Godase",
            studentId: "GCP1",
            level: 1,
          ),
        ),
        GoRoute(
          path: '/assessment-workflow',
          builder: (context, state) => AssessmentWorkflowScreenFigma(),
        ),
        GoRoute(
          path: '/assessment-type',
          builder: (context, state) => ChooseAssessmentTypeScreen(),
        ),
        GoRoute(
          path: '/studentlist',
          builder: (context, state) => StudentListScreenFigma(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreenFigma(),
        ),
      ],
    ),
  ],
);
