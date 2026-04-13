import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final familyProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .doc(userId)
      .collection('familyMembers')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
});

final currentUserFamilyProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return ref.watch(familyProvider(user.uid));
});

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addFamilyMember(Map<String, dynamic> memberData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('familyMembers')
        .add({
          ...memberData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateFamilyMember(String memberId, Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('familyMembers')
        .doc(memberId)
        .update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> deleteFamilyMember(String memberId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('familyMembers')
        .doc(memberId)
        .delete();
  }

  Future<Map<String, dynamic>?> getFamilyMember(String memberId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('familyMembers')
        .doc(memberId)
        .get();

    if (doc.exists) {
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    }
    return null;
  }

  Future<int> getAvailableFamilySlots() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    final purchasedSlots = data?['subscription']?['familySlots'] ?? 0;
    final currentMembers = await getFamilyMemberCount();

    return purchasedSlots - currentMembers;
  }

  Future<int> getFamilyMemberCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('familyMembers')
        .get();

    return snapshot.size;
  }
}