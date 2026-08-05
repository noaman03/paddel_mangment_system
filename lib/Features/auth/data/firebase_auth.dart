// ignore_for_file: camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:padel_management_system/core/Service/firebase/firebase_store.dart';

class firebase_auth {
  FirebaseAuth? _auth;
  bool _authResolved = false;

  /// `FirebaseAuth.instance` resolved lazily and defensively.
  ///
  /// This used to be a field initializer, which made merely *constructing* this
  /// class fatal: `main` deliberately lets `Firebase.initializeApp` fail and
  /// continues in offline demo mode, and in that state the getter throws
  /// ("No Firebase App '[DEFAULT]' has been created", or a MissingPluginException
  /// on desktop). The exception escaped through the Riverpod providers into the
  /// first screen's `build`. Returns null when Firebase is unavailable so every
  /// caller can degrade instead of crashing.
  FirebaseAuth? get _authOrNull {
    if (_authResolved) return _auth;
    _authResolved = true;
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase Auth unavailable, offline demo mode: $e');
      _auth = null;
    }
    return _auth;
  }

  /// Whether a real Firebase Auth backend is reachable.
  bool get isAvailable => _authOrNull != null;

  // Sign in with email and password
  Future<User?> login(String email, String password) async {
    final auth = _authOrNull;
    if (auth == null) return null;
    try {
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Login failed: $e');
      return null;
    }
  }

  /// Registers a new account.
  ///
  /// The guard used to be a positive `if (…everything is valid…)` wrapper: when
  /// it was false the method fell through to a "User registered successfully!"
  /// log and returned normally, so a mismatched password reported success and
  /// the caller then failed downstream with a confusing `user-not-found`.
  /// Every invalid input now throws with the real reason.
  Future<void> signup({
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
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      throw Exception('First and last name are required');
    }
    if (password.isEmpty) {
      throw Exception('Password is required');
    }
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    final String collectionName;
    switch (role) {
      case 'player':
        collectionName = 'players';
      case 'owner':
        collectionName = 'owner';
      case 'admin':
        collectionName = 'admin';
      default:
        throw Exception('Invalid role provided: "$role"');
    }

    final auth = _authOrNull;
    if (auth == null) {
      throw Exception('Signup is unavailable: this build runs offline.');
    }

    try {
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await FirebaseStore().createuser(
        collectionname: collectionName,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phonenumber: phonenumber,
        birthdate: birthdate,
        gender: gender,
      );
      debugPrint('User registered successfully.');
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Sign out
  Future<void> logout() async {
    await _authOrNull?.signOut();
  }

  // Password reset
  Future<void> resetPassword({required String email}) async {
    final auth = _authOrNull;
    if (auth == null) {
      throw Exception(
          'Password reset is unavailable: this build runs offline.');
    }
    await auth.sendPasswordResetEmail(email: email);
  }

  // Get current user
  User? getCurrentUser() {
    return _authOrNull?.currentUser;
  }
}
