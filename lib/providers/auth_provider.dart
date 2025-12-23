import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.error,
  });

  AuthState copyWith({bool? isLoading, bool? isAuthenticated, String? userId, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // In production, use Firebase Auth
      // For now, simulate signup
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void signInAsGuest() {
    state = state.copyWith(
      isAuthenticated: true,
      userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void signOut() {
    state = const AuthState();
  }
}
