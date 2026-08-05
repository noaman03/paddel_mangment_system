/// A stored user profile.
///
/// The field names mirror what `FirebaseStore.createuser` actually writes
/// (`firstName` / `lastName`, not `name`), and every read is defensive: the
/// previous `map['name']` cast blew up with "type Null is not a subtype of type
/// String" on documents this very app had created.
class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? gender;
  final String? avatarImage;

  const UserModel({
    required this.uid,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.role = 'player',
    this.phoneNumber,
    this.gender,
    this.avatarImage,
  });

  String get name {
    final full = '$firstName $lastName'.trim();
    if (full.isNotEmpty) return full;
    return email.isNotEmpty ? email.split('@').first : 'Player';
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final combined = '$first$last'.trim();
    return combined.isEmpty ? '?' : combined.toUpperCase();
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final legacyName = map['name']?.toString().trim() ?? '';
    final parts = legacyName.split(' ');
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      firstName:
          map['firstName']?.toString() ?? (parts.isNotEmpty ? parts.first : ''),
      lastName: map['lastName']?.toString() ??
          (parts.length > 1 ? parts.sublist(1).join(' ') : ''),
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'player',
      phoneNumber: map['phonenumber']?.toString(),
      gender: map['gender']?.toString(),
      avatarImage: map['avatarImage']?.toString(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? phoneNumber,
    String? gender,
    String? avatarImage,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      avatarImage: avatarImage ?? this.avatarImage,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'phonenumber': phoneNumber,
        'gender': gender,
        'avatarImage': avatarImage,
      };
}
