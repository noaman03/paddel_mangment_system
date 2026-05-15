import 'package:firebase_auth/firebase_auth.dart';
import 'package:padelsystem/core/Service/firebase/firebase_store.dart';

class firebase_auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

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
    try {
      if (email.isNotEmpty &&
          role.isNotEmpty &&
          password.isNotEmpty &&
          firstName.isNotEmpty &&
          lastName.isNotEmpty &&
          password == confirmPassword) {
        await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim());
        String collectionName;
        if (role == "player") {
          collectionName = "players";
        } else if (role == "owner") {
          collectionName = "owner";
        } else if (role == "admin") {
          collectionName = "admin";
        } else {
          throw Exception("Invalid role provided");
        }
        await FirebaseStore().createuser(
            collectionname: collectionName,
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role,
            phonenumber: phonenumber,
            birthdate: birthdate,
            gender: gender);
      }
      print("User registered successfully!");
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
