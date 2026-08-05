// ignore_for_file: camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_management_system/Features/auth/data/firebase_auth.dart';

// Auth state class to track authentication status
class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  // Create a copy with updated fields
  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth notifier to manage authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final firebase_auth _firebaseAuth;

  AuthNotifier(this._firebaseAuth) : super(const AuthState()) {
    // Check if user is already logged in when initializing
    _getCurrentUser();
  }

  // Get current logged-in user.
  //
  // Goes through the service rather than `FirebaseAuth.instance` so an offline
  // build (where `Firebase.initializeApp` failed) yields null instead of
  // throwing out of whatever widget first watched this provider.
  void _getCurrentUser() {
    try {
      final currentUser = _firebaseAuth.getCurrentUser();
      if (currentUser != null) {
        state = state.copyWith(user: currentUser);
      }
    } catch (e) {
      debugPrint('Could not read the current user: $e');
    }
  }

  // Sign in with email and password
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final user = await _firebaseAuth.login(email, password);

      if (user != null) {
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(
            isLoading: false,
            errorMessage: "Login failed. Please check your credentials.");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error: ${e.toString()}",
      );
    }
  }

  // Register a new user
  Future<User?> signup({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String confirmPassword,
    required String role,
    required int phonenumber,
    required DateTime birthdate,
    required String gender,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _firebaseAuth.signup(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        phonenumber: phonenumber,
        birthdate: birthdate,
        gender: gender,
      );

      // Firebase populates `currentUser` asynchronously right after the
      // account is created, so give it one short retry before giving up.
      var user = _firebaseAuth.getCurrentUser();
      if (user == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        user = _firebaseAuth.getCurrentUser();
      }
      if (user == null) {
        throw Exception('User ID not available after registration');
      }

      state = state.copyWith(isLoading: false, user: user);

      return user;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Registration failed: ${e.toString()}",
      );
      rethrow; // Allow handling upstream
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _firebaseAuth.logout();
      state = const AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Sign out failed: ${e.toString()}",
      );
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _firebaseAuth.resetPassword(email: email);
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Password reset failed: ${e.toString()}",
      );
    }
  }

  // Clear any error message
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

// Provider for the Firebase auth service
final firebaseAuthProvider = Provider<firebase_auth>((ref) {
  return firebase_auth();
});

// Auth state notifier provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthNotifier(firebaseAuth);
});

// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).user != null;
});

// Provider to get the current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});
