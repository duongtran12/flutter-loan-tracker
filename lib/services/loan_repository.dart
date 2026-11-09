import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/loan_record.dart';

class LoanRepository {
  LoanRepository({FirebaseFirestore? firestore})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection(
        'loan_records',
      );

  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<LoanRecord>> watchRecords() {
    return _collection.snapshots().map((snapshot) {
      final records = snapshot.docs
          .map((doc) => LoanRecord.fromMap(doc.id, doc.data()))
          .toList();
      records.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
      return records;
    });
  }

  Future<void> addRecord(LoanRecord record) async {
    final document = _collection.doc();
    await document.set(record.copyWith(id: document.id).toMap());
  }

  Future<void> updateRecord(LoanRecord record) {
    return _collection.doc(record.id).update(record.toMap());
  }

  Future<void> deleteRecord(String id) {
    return _collection.doc(id).delete();
  }
}
