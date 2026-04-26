import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String name;
  final DateTime dob;
  final String phone;
  final bool isAstrologer;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.dob,
    required this.phone,
    this.isAstrologer = false,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      dob: (map['dob'] as Timestamp).toDate(),
      isAstrologer: map['isAstrologer'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'dob': Timestamp.fromDate(dob),
    'isAstrologer': isAstrologer,
  };
}

// ─── Repository ───────────────────────────────────────────────────────────────
final _auth = FirebaseAuth.instance;
final _db = FirebaseFirestore.instance;

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value(null);

  return _db.collection('users').doc(user.uid).snapshots().map((doc) {
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromMap(user.uid, doc.data()!);
  });
});


// Fetches from users collection first, falls back to astrologers collection
final astrologerProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value(null);

  return _db.collection('users').doc(user.uid).snapshots().asyncMap((doc) async {
    if (doc.exists && doc.data() != null && (doc.data()!['name'] ?? '').isNotEmpty) {
      return UserProfile.fromMap(user.uid, doc.data()!);
    }
    // Fallback: check astrologers collection
    final astroDoc = await _db.collection('astrologers').doc(user.uid).get();
    if (astroDoc.exists && astroDoc.data() != null) {
      return UserProfile.fromMap(user.uid, astroDoc.data()!);
    }
    return null;
  });
});

final saveUserProfileProvider = Provider((ref) => _saveProfile);

Future<void> _saveProfile(UserProfile profile) async {
  await _db.collection('users').doc(profile.uid).set(
    profile.toMap(), SetOptions(merge: true),
  );
}
