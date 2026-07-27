import 'package:firebase_auth/firebase_auth.dart';
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

  // Get current logged-in user
  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      state = state.copyWith(user: currentUser);
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

      // Important: Get the updated user manually after registration
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId == null) {
        // Wait briefly and try again
        await Future.delayed(const Duration(milliseconds: 500));
        final retryUser = FirebaseAuth.instance.currentUser;
        final retryUserId = retryUser?.uid;

        if (retryUserId == null) {
          throw Exception('User ID not available after registration');
        }

        // Continue with retryUserId
      }

      // Continue with userId

      // Update the state with the user
      state = state.copyWith(isLoading: false, user: user);

      return user;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Registration failed: ${e.toString()}",
      );
      throw e; // Re-throw to allow handling upstream
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await FirebaseAuth.instance.signOut();
      state = AuthState(); // Reset to initial state
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
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
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
