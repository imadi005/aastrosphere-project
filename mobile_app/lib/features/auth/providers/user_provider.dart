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
    DateTime dob;
    try {
      dob = (map['dob'] as Timestamp).toDate();
    } catch (_) {
      // dob missing or wrong type — use placeholder so app doesn't crash
      dob = DateTime(1990, 1, 1);
    }
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      dob: dob,
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
    // Check users collection first — needs both name and dob
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      if ((data['name'] ?? '').toString().isNotEmpty && data['dob'] != null) {
        return UserProfile.fromMap(user.uid, data);
      }
    }
    // Fallback: check astrologers collection
    try {
      final astroDoc = await _db.collection('astrologers').doc(user.uid).get();
      if (astroDoc.exists && astroDoc.data() != null) {
        final aData = astroDoc.data()!;
        if (aData['dob'] != null) {
          return UserProfile.fromMap(user.uid, aData);
        }
      }
    } catch (_) {}
    // Last fallback: use users data even if dob missing (fromMap handles it gracefully)
    if (doc.exists && doc.data() != null && (doc.data()!['name'] ?? '').toString().isNotEmpty) {
      return UserProfile.fromMap(user.uid, doc.data()!);
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
