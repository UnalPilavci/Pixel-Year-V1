import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;
  Future<void> addPixel(DateTime date, int color, String note, int? iconCode) async {
    if (_uid == null) return;
    String docId = "${date.year}-${date.month}-${date.day}";
    await _db.collection('users').doc(_uid).collection('moods').doc(docId).set({
      'date': Timestamp.fromDate(date),
      'color': color,
      'note': note,
      'icon': iconCode,
      'updatedAt': Timestamp.now(),
    });
  }
  Future<void> deletePixel(DateTime date) async {
    if (_uid == null) return;
    String docId = "${date.year}-${date.month}-${date.day}";
    await _db.collection('users').doc(_uid).collection('moods').doc(docId).delete();
  }
  Stream<QuerySnapshot> getPixelsStream() {
    if (_uid == null) return const Stream.empty();
    return _db.collection('users').doc(_uid).collection('moods').orderBy('date', descending: true).snapshots();
  }
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    if (_uid == null || query.isEmpty) return [];
    final snapshot = await _db.collection('users').doc(_uid).collection('moods').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'note': data['note'] ?? '',
        'color': data['color'],
        'realDate': (data['date'] as Timestamp).toDate(),
        'icon': data['icon'],
      };
    }).where((data) => data['note'].toString().toLowerCase().contains(query.toLowerCase())).toList();
  }
  Future<void> addGratitude(String text) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('gratitudes').add({
      'text': text,
      'date': Timestamp.now(),
    });
  }
  Stream<QuerySnapshot> getGratitudesStream() {
    if (_uid == null) return const Stream.empty();
    return _db.collection('users').doc(_uid).collection('gratitudes').orderBy('date', descending: true).snapshots();
  }
  Future<void> deleteGratitude(String docId) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('gratitudes').doc(docId).delete();
  }
  Future<void> addFutureLetter(String note, DateTime unlockDate) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('future_letters').add({
      'note': note,
      'unlockDate': Timestamp.fromDate(unlockDate),
      'createdAt': Timestamp.now(),
    });
  }
  Stream<QuerySnapshot> getFutureLettersStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('future_letters')
        .orderBy('unlockDate', descending: false)
        .snapshots();
  }
  Future<void> deleteFutureLetter(String docId) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('future_letters').doc(docId).delete();
  }

}