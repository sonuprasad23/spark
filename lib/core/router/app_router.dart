import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/chat/presentation/screens/decision_day_screen.dart';
import '../../features/profile/presentation/screens/profile_editor_screen.dart';
import '../../features/profile/presentation/screens/premium_screen.dart';

/// Route names for type-safe navigation
class Routes {
  Routes._();
  
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String phoneLogin = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String matches = '/matches';
  static const String chatRoom = '/chat-room';
  static const String decisionDay = '/decision-day';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String premium = '/premium';
  static const String settings = '/settings';
}

/// Router provider for Riverpod
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Flow
      GoRoute(
        path: Routes.welcome,
        name: 'welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: Routes.phoneLogin,
        name: 'phoneLogin',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PhoneLoginScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: Routes.otpVerification,
        name: 'otpVerification',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: OtpVerificationScreen(phoneNumber: phoneNumber),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      
      // Onboarding
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingFlowScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      
      // Main App (with bottom navigation)
      GoRoute(
        path: Routes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      
      // Chat Room
      GoRoute(
        path: Routes.chatRoom,
        name: 'chatRoom',
        pageBuilder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: ChatRoomScreen(
              roomId: params['roomId'] ?? '',
              matchName: params['matchName'] ?? '',
              dayNumber: params['dayNumber'] ?? 1,
              compatibilityScore: params['compatibilityScore'] ?? 85,
            ),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      
      // Decision Day
      GoRoute(
        path: Routes.decisionDay,
        name: 'decisionDay',
        pageBuilder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: DecisionDayScreen(
              roomId: params['roomId'] ?? '',
              matchName: params['matchName'] ?? '',
              compatibilityScore: params['compatibilityScore'] ?? 85,
              messagesExchanged: params['messagesExchanged'] ?? 0,
              isPremium: params['isPremium'] ?? false,
            ),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      
      // Profile Editor
      GoRoute(
        path: Routes.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileEditorScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      
      // Premium
      GoRoute(
        path: Routes.premium,
        name: 'premium',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PremiumScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// Slide transition from right
Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeOutCubic;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}

/// Slide transition from bottom (for modals)
Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(0.0, 1.0);
  const end = Offset.zero;
  const curve = Curves.easeOutCubic;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
