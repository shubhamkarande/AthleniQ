import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/signup_screen.dart';
import '../screens/onboarding/login_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/workout/workout_list_screen.dart';
import '../screens/workout/workout_session_screen.dart';
import '../screens/workout/workout_summary_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String workoutList = '/workout-list';
  static const String workoutSession = '/workout-session';
  static const String workoutSummary = '/workout-summary';
  static const String progress = '/progress';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      
      case welcome:
        return _slideRoute(const WelcomeScreen(), settings);
      
      case signup:
        return _slideRoute(const SignupScreen(), settings);
      
      case login:
        return _slideRoute(const LoginScreen(), settings);
      
      case profileSetup:
        return _slideRoute(const ProfileSetupScreen(), settings);
      
      case home:
        return _fadeRoute(const HomeScreen(), settings);
      
      case workoutList:
        return _slideRoute(const WorkoutListScreen(), settings);
      
      case workoutSession:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          WorkoutSessionScreen(
            exerciseType: args?['exerciseType'] ?? 'squat',
            exerciseName: args?['exerciseName'] ?? 'Squats',
          ),
          settings,
        );
      
      case workoutSummary:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          WorkoutSummaryScreen(
            workoutData: args ?? {},
          ),
          settings,
        );
      
      case progress:
        return _slideRoute(const ProgressScreen(), settings);
      
      case AppRoutes.settings:
        return _slideRoute(const SettingsScreen(), settings);
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
