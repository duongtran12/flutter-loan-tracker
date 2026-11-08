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
    this.imagePath,
  });

  final String id;
  final String itemName;
  final String borrowerName;
  final DateTime borrowDate;
  final DateTime dueDate;
  final LoanStatus status;
  final String note;
  final String? imagePath;

  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return status == LoanStatus.borrowing && due.isBefore(today);
  }

  LoanRecord copyWith({
    String? itemName,
    String? borrowerName,
    DateTime? borrowDate,
    DateTime? dueDate,
    LoanStatus? status,
    String? note,
    String? imagePath,
  }) {
    return LoanRecord(
      id: id,
      itemName: itemName ?? this.itemName,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

String formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}
