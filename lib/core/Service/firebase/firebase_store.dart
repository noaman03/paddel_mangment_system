import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseStore {
  /// Firestore/Auth handles, resolved lazily.
  ///
  /// `FirebaseFirestore.instance` throws when `Firebase.initializeApp` never
  /// succeeded, which is the normal case for this offline build. As *field
  /// initializers* those throws happened while the Riverpod provider was being
  /// constructed — before any of the offline fallbacks below could run — so
  /// they are resolved on demand and null-tolerantly instead.
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore unavailable: $e');
      return null;
    }
  }

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase Auth unavailable: $e');
      return null;
    }
  }

  /// How long a write may block the UI before the demo gives up on the backend.
  ///
  /// Firestore keeps offline writes pending until a server acknowledges them,
  /// so `await set(...)` never completes in this build and the signup screen
  /// used to spin forever.
  static const Duration writeTimeout = Duration(seconds: 3);

  //create user
  Future<void> createuser({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    required int phonenumber,
    required DateTime birthdate,
    required String gender,
    required String collectionname,
  }) async {
    final FirebaseAuth? auth = _auth;
    final User? user = auth?.currentUser;
    if (user == null) {
      // Previously `user!.uid` threw here and a blanket catch swallowed it, so
      // signup reported success with no profile written anywhere.
      throw StateError(
        auth == null
            ? 'Firebase is not initialised — cannot create a profile.'
            : 'No signed-in user to create a profile for.',
      );
    }

    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) {
      // Same contract as the timeout below: the demo carries on without a
      // backend rather than failing the signup.
      debugPrint(
          'Firestore unavailable — profile for ${user.uid} not written.');
      return;
    }

    await firestore.collection(collectionname).doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'phonenumber': phonenumber,
      'birthdate': birthdate,
      'gender': gender,
    }).timeout(
      writeTimeout,
      onTimeout: () {
        // Offline demo: the write stays queued locally, the user moves on.
        debugPrint(
          'Firestore unreachable — profile for ${user.uid} queued locally.',
        );
      },
    );
  }
}
