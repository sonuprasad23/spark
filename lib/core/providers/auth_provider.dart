import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

/// Authentication state
enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  onboarding,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final SparkUser? user;
  final String? error;
  final String? verificationId;
  final String? phoneNumber;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.verificationId,
    this.phoneNumber,
  });

  AuthState copyWith({
    AuthStatus? status,
    SparkUser? user,
    String? error,
    String? verificationId,
    String? phoneNumber,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.authenticating;
  bool get needsOnboarding => status == AuthStatus.onboarding;
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Initialize auth - check for existing session
  Future<void> initialize() async {
    try {
      // TODO: Check for stored auth token / Firebase user
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For now, start as unauthenticated
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      state = state.copyWith(
        status: AuthStatus.authenticating,
        phoneNumber: phoneNumber,
        error: null,
      );

      // TODO: Implement Firebase phone auth
      await Future.delayed(const Duration(seconds: 1));

      // Simulate verification ID
      state = state.copyWith(
        verificationId: 'verification_${DateTime.now().millisecondsSinceEpoch}',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    try {
      state = state.copyWith(
        status: AuthStatus.authenticating,
        error: null,
      );

      // TODO: Verify OTP with Firebase
      await Future.delayed(const Duration(seconds: 1));

      // Check if user exists or needs onboarding
      final isNewUser = true; // TODO: Check from Firestore

      if (isNewUser) {
        state = state.copyWith(status: AuthStatus.onboarding);
      } else {
        // Load existing user
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: SparkUser.sample,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(
        status: AuthStatus.authenticating,
        error: null,
      );

      // TODO: Implement Google Sign-in
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(status: AuthStatus.onboarding);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Complete onboarding
  Future<bool> completeOnboarding(SparkUser userData) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);

      // TODO: Save user to Firestore
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userData,
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(SparkUser updatedUser) async {
    try {
      // TODO: Update in Firestore
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // TODO: Sign out from Firebase
      await Future.delayed(const Duration(milliseconds: 300));

      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier();
  notifier.initialize();
  return notifier;
});

/// Current user provider (convenience)
final currentUserProvider = Provider<SparkUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Is premium provider
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isPremium ?? false;
});
