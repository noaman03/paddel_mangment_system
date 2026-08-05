import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Storage helpers.
///
/// This is an offline portfolio build: there is no Storage bucket to talk to,
/// so every call here fails fast instead of retrying for the default two
/// minutes (which made the signup button look frozen), and the user-facing
/// avatar path degrades to the bundled asset rather than throwing.
class FirebaseStorageService {
  FirebaseStorageService() {
    final FirebaseStorage? storage = _storage;
    if (storage == null) return;
    try {
      storage.setMaxOperationRetryTime(const Duration(seconds: 5));
      storage.setMaxUploadRetryTime(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Firebase Storage not configured: $e');
    }
  }

  /// Backend handles, resolved lazily.
  ///
  /// `FirebaseStorage.instance` / `FirebaseFirestore.instance` throw when
  /// `Firebase.initializeApp` never succeeded. As *field initializers* they ran
  /// before the constructor body — so the try/catch above could not help and
  /// simply building this service took the signup screen down.
  FirebaseStorage? get _storage {
    try {
      return FirebaseStorage.instance;
    } catch (e) {
      debugPrint('Firebase Storage unavailable: $e');
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore unavailable: $e');
      return null;
    }
  }

  /// The Storage handle, or a thrown [Exception] the callers below already
  /// translate into their own fallback (local asset / surfaced error).
  FirebaseStorage get _requireStorage =>
      _storage ?? (throw Exception('Firebase Storage is not available.'));

  /// Best-effort `set(merge: true)`. Never throws for a missing backend, and
  /// never blocks longer than [_timeout] — offline Firestore keeps a write
  /// pending forever, which is what used to freeze the signup button.
  Future<void> _mergeDoc(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) {
      debugPrint(
          'Firestore unavailable — $collection/$documentId not updated.');
      return;
    }
    await firestore
        .collection(collection)
        .doc(documentId)
        .set(data, SetOptions(merge: true))
        .timeout(_timeout, onTimeout: () {});
  }

  static const Duration _timeout = Duration(seconds: 6);

  // Upload player profile image
  Future<String> uploadProfileImage(String userId, Uint8List file) async {
    try {
      final Reference ref =
          _requireStorage.ref().child('profile_images').child(userId);
      final TaskSnapshot snapshot = await ref.putData(file).timeout(_timeout);
      final String downloadUrl =
          await snapshot.ref.getDownloadURL().timeout(_timeout);

      // set(merge) rather than update(): the document may not exist yet, and
      // update() fails with NOT_FOUND after the file has already been stored.
      await _mergeDoc('players', userId, {'profileImageUrl': downloadUrl});

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Persists the avatar the player picked during signup.
  ///
  /// Returns the remote URL when Storage is reachable and the local asset path
  /// otherwise, so the signup flow always completes.
  Future<String> uploadPlayerAvatar(
      String userId, String assetImagePath) async {
    try {
      final ByteData bytes = await rootBundle.load(assetImagePath);
      final Uint8List imageData = bytes.buffer.asUint8List();

      final String fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          _requireStorage.ref().child('avatars').child(userId).child(fileName);

      final TaskSnapshot snapshot = await ref
          .putData(imageData, SettableMetadata(contentType: 'image/jpeg'))
          .timeout(_timeout);
      final String downloadUrl =
          await snapshot.ref.getDownloadURL().timeout(_timeout);

      await _mergeDoc('players', userId, {'avatarImage': downloadUrl});

      return downloadUrl;
    } catch (e) {
      debugPrint('Avatar upload unavailable, keeping local asset: $e');
      _rememberLocalAvatar(userId, assetImagePath);
      return assetImagePath;
    }
  }

  void _rememberLocalAvatar(String userId, String assetImagePath) {
    // Fire-and-forget: the demo must not wait on a backend that is not there.
    _mergeDoc('players', userId, {'avatarImage': assetImagePath})
        .catchError((Object e) => debugPrint('Local avatar not persisted: $e'));
  }

  // Upload document files for player (ID, certificates, etc.)
  Future<String> uploadPlayerDocument(
      String userId, Uint8List fileBytes, String fileName) async {
    try {
      final Reference ref = _requireStorage
          .ref()
          .child('player_documents')
          .child(userId)
          .child(fileName);

      final TaskSnapshot snapshot =
          await ref.putData(fileBytes).timeout(_timeout);
      final String downloadUrl =
          await snapshot.ref.getDownloadURL().timeout(_timeout);

      await _mergeDoc('players', userId, {
        'documents': FieldValue.arrayUnion([
          {
            'url': downloadUrl,
            'filename': fileName,
            'uploadDate': DateTime.now().toIso8601String(),
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
      final List<String> downloadUrls = [];

      for (int i = 0; i < files.length; i++) {
        final Reference ref = _requireStorage
            .ref()
            .child('match_media')
            .child(matchId)
            .child(fileNames[i]);

        final TaskSnapshot snapshot =
            await ref.putData(files[i]).timeout(_timeout);
        downloadUrls.add(await snapshot.ref.getDownloadURL().timeout(_timeout));
      }

      await _mergeDoc('matches', matchId, {
        'media': FieldValue.arrayUnion(
          downloadUrls
              .map((url) => {
                    'url': url,
                    'uploadDate': DateTime.now().toIso8601String(),
                  })
              .toList(),
        )
      });

      return downloadUrls;
    } catch (e) {
      throw Exception('Error uploading match media: $e');
    }
  }

  // Delete a file from storage
  Future<void> deleteFile(String path) async {
    try {
      await _requireStorage.ref(path).delete().timeout(_timeout);
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  // Get download URL for a file
  Future<String> getDownloadURL(String path) async {
    try {
      return await _requireStorage.ref(path).getDownloadURL().timeout(_timeout);
    } catch (e) {
      throw Exception('Error getting download URL: $e');
    }
  }

  // Upload court images for owners
  Future<List<String>> uploadCourtImages(
      String courtId, List<Uint8List> images) async {
    try {
      final List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        final String fileName =
            'court_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final Reference ref = _requireStorage
            .ref()
            .child('court_images')
            .child(courtId)
            .child(fileName);

        final TaskSnapshot snapshot =
            await ref.putData(images[i]).timeout(_timeout);
        imageUrls.add(await snapshot.ref.getDownloadURL().timeout(_timeout));
      }

      await _mergeDoc(
        'courts',
        courtId,
        {'images': FieldValue.arrayUnion(imageUrls)},
      );

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload court images: $e');
    }
  }
}
