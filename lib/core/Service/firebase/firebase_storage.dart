import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class FirebaseStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload player profile image
  Future<String> uploadProfileImage(String userId, Uint8List file) async {
    try {
      Reference ref = _storage.ref().child('profile_images').child(userId);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user document with the profile image URL
      await _firestore.collection('players').doc(userId).update({
        'profileImageUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Upload player avatar from assets to Firebase Storage
  Future<String> uploadPlayerAvatar(
      String userId, String assetImagePath) async {
    try {
      // 1. Load asset image as bytes
      final ByteData bytes = await rootBundle.load(assetImagePath);
      final Uint8List imageData = bytes.buffer.asUint8List();

      // 2. Upload to Firebase Storage
      final String fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          _storage.ref().child('avatars').child(userId).child(fileName);

      final UploadTask uploadTask =
          ref.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));

      // 3. Get download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Save URL to Firestore
      await _firestore.collection('players').doc(userId).set({
        'avatarImage': downloadUrl,
      }, SetOptions(merge: true));

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  // Upload document files for player (ID, certificates, etc.)
  Future<String> uploadPlayerDocument(
      String userId, Uint8List fileBytes, String fileName) async {
    try {
      // Reference to the file
      Reference ref = _storage
          .ref()
          .child('player_documents')
          .child(userId)
          .child(fileName);

      // Upload the file
      UploadTask uploadTask = ref.putData(fileBytes);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the URL to Firestore
      await _firestore.collection('players').doc(userId).update({
        'documents': FieldValue.arrayUnion([
          {
            'url': downloadUrl,
            'filename': fileName,
            'uploadDate': FieldValue.serverTimestamp(),
          }
        ])
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  // Upload match photos or videos
  Future<List<String>> uploadMatchMedia(
      String matchId, List<Uint8List> files, List<String> fileNames) async {
    try {
      List<String> downloadUrls = [];

      for (int i = 0; i < files.length; i++) {
        Reference ref = _storage
            .ref()
            .child('match_media')
            .child(matchId)
            .child(fileNames[i]);

        UploadTask uploadTask = ref.putData(files[i]);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      // Add media to match document
      await _firestore.collection('matches').doc(matchId).update({
        'media': FieldValue.arrayUnion(downloadUrls
            .map((url) => {
                  'url': url,
                  'uploadDate': FieldValue.serverTimestamp(),
                })
            .toList())
      });

      return downloadUrls;
    } catch (e) {
      throw Exception('Error uploading match media: $e');
    }
  }

  // Delete a file from storage
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  // Get download URL for a file
  Future<String> getDownloadURL(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      throw Exception('Error getting download URL: $e');
    }
  }

  // Upload court images for owners
  Future<List<String>> uploadCourtImages(
      String courtId, List<Uint8List> images) async {
    try {
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        String fileName =
            'court_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref =
            _storage.ref().child('court_images').child(courtId).child(fileName);

        UploadTask task = ref.putData(images[i]);
        TaskSnapshot snapshot = await task;
        String url = await snapshot.ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Update court document with image URLs
      await _firestore.collection('courts').doc(courtId).update({
        'images': FieldValue.arrayUnion(imageUrls),
      });

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload court images: $e');
    }
  }
}
