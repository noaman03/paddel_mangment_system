import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user
  Future<void> createuser(
      {required String email,
      required String firstName,
      required String lastName,
      required String role,
      required int phonenumber,
      required DateTime birthdate,
      required String gender,
      required collectionname}) async {
    try {
      User? user = _auth.currentUser;
      await _firestore.collection(collectionname).doc(user!.uid).set({
        'uid': user.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'phonenumber': phonenumber,
        'birthdate': birthdate,
        'gender': gender
      });
    } catch (e) {
      print(e);
    }
  }
}
