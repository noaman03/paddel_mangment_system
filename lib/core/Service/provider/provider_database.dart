import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padelsystem/core/Service/firebase/firebase_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Database operation state class
class DatabaseState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? data;
  final bool isSuccess;

  const DatabaseState({
    this.isLoading = false,
    this.error,
    this.data,
    this.isSuccess = false,
  });

  // Create a copy with updated fields
  DatabaseState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? data,
    bool? isSuccess,
  }) {
    return DatabaseState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // null will clear the error
      data: data ?? this.data,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Database notifier to handle Firestore operations
class DatabaseNotifier extends StateNotifier<DatabaseState> {
  final FirebaseStore _firestoreService;

  DatabaseNotifier(this._firestoreService) : super(const DatabaseState());

  // Create new user in Firestore
  Future<void> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    required int phonenumber,
    required DateTime birthdate,
    required String gender,
    String collectionname = 'players', // Default collection
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _firestoreService.createuser(
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phonenumber: phonenumber,
        birthdate: birthdate,
        gender: gender,
        collectionname: collectionname,
      );

      // Create user data object to return in state
      final userData = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'phonenumber': phonenumber,
        'birthdate': birthdate,
        'gender': gender,
      };

      state = state.copyWith(
        isLoading: false,
        data: userData,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create user: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  // Get user data from Firestore
  Future<void> getUserData(String userId,
      {String collection = 'players'}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(userId)
          .get();

      if (snapshot.exists) {
        state = state.copyWith(
          isLoading: false,
          data: snapshot.data(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'User not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error fetching user data: ${e.toString()}',
      );
    }
  }

  // Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data,
      {String collection = 'players'}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(userId)
          .update(data);

      state = state.copyWith(
        isLoading: false,
        data: data,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update user data: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  // Delete user data
  Future<void> deleteUser(String userId,
      {String collection = 'players'}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(userId)
          .delete();

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete user: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  // Clear any error messages
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

// Provider for the Firebase Firestore service
final firestoreServiceProvider = Provider<FirebaseStore>((ref) {
  return FirebaseStore();
});

// Database state notifier provider
final databaseProvider =
    StateNotifierProvider<DatabaseNotifier, DatabaseState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return DatabaseNotifier(firestoreService);
});
