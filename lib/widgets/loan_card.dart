import 'package:flutter/material.dart';

import '../models/loan_record.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({super.key, required this.record, required this.onTap});

  final LoanRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = record.isOverdue
        ? const Color(0xFFE55555)
        : record.status == LoanStatus.returned
        ? const Color(0xFF2F9B69)
        : const Color(0xFF3157D5);
    final statusText = record.isOverdue
        ? 'Quá hạn'
        : record.status == LoanStatus.returned
        ? 'Đã trả'
        : 'Đang mượn';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7E9F1)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: record.imageUrl == null || record.imageUrl!.isEmpty
                      ? Container(
                          color: const Color(0xFFEEF1FA),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF6F7A96),
                            size: 34,
                          ),
                        )
                      : Image.network(
                          record.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: Color(0xFFEEF1FA),
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF9CA4BA),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('Người mượn: ${record.borrowerName}'),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Hạn ${formatDate(record.dueDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF69728A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
