import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- NAYE PROVIDERS ---
// Firestore ka instance
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// Auth Repository ka provider (ab Firestore bhi use karega)
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  ),
);
// --------------------

// Auth State Stream (Same as before)
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final authStateChangesProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// User Data Provider (Naya)
// Yeh provider logged-in user ka *dono* role ka data laayega
final userRolesProvider = FutureProvider<Map<String, DocumentSnapshot?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final uid = authRepository.getCurrentUserId();
  if (uid == null) {
    return {};
  }
  return authRepository.getUserRoles(uid);
});


class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore; // NAYA

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore, // NAYA
  })  : _auth = auth,
        _firestore = firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? getCurrentUserId() => _auth.currentUser?.uid;

  // --- NAYA FUNCTION ---
  // Yeh function check karega ki user 'users' aur 'astrologers' collection mein hai ya nahi
  Future<Map<String, DocumentSnapshot?>> getUserRoles(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final astrologerDoc = await _firestore.collection('astrologers').doc(uid).get();

    return {
      'User': userDoc.exists ? userDoc : null,
      'Astrologer': astrologerDoc.exists ? astrologerDoc : null,
    };
  }
}