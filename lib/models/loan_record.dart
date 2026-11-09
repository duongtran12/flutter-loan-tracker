enum LoanStatus { borrowing, returned }

class LoanRecord {
  const LoanRecord({
    required this.id,
    required this.itemName,
    required this.borrowerName,
    required this.borrowDate,
    required this.dueDate,
    required this.status,
    this.note = '',
    this.imageUrl,
  });

  final String id;
  final String itemName;
  final String borrowerName;
  final DateTime borrowDate;
  final DateTime dueDate;
  final LoanStatus status;
  final String note;
  final String? imageUrl;

  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return status == LoanStatus.borrowing && due.isBefore(today);
  }

  LoanRecord copyWith({
    String? id,
    String? itemName,
    String? borrowerName,
    DateTime? borrowDate,
    DateTime? dueDate,
    LoanStatus? status,
    String? note,
    String? imageUrl,
  }) {
    return LoanRecord(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory LoanRecord.fromMap(String id, Map<String, dynamic> map) {
    return LoanRecord(
      id: id,
      itemName: map['itemName'] as String? ?? '',
      borrowerName: map['borrowerName'] as String? ?? '',
      borrowDate: DateTime.fromMillisecondsSinceEpoch(
        map['borrowDate'] as int? ?? 0,
      ),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int? ?? 0),
      status: map['status'] == LoanStatus.returned.name
          ? LoanStatus.returned
          : LoanStatus.borrowing,
      note: map['note'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'borrowerName': borrowerName,
      'borrowDate': borrowDate.millisecondsSinceEpoch,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status.name,
      'note': note,
      'imageUrl': imageUrl,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

String formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}
