import 'package:flutter/material.dart';

import '../models/loan_record.dart';
import 'loan_form_screen.dart';

class LoanDetailResult {
  const LoanDetailResult({required this.record, this.deleted = false});

  final LoanRecord record;
  final bool deleted;
}

class LoanDetailScreen extends StatefulWidget {
  const LoanDetailScreen({super.key, required this.record});

  final LoanRecord record;

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  late LoanRecord _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<LoanRecord>(
      MaterialPageRoute(builder: (_) => LoanFormScreen(record: _record)),
    );

    if (updated != null && mounted) {
      setState(() => _record = updated);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lượt mượn?'),
        content: Text(
          'Thông tin “${_record.itemName}” sẽ bị xóa khỏi danh sách.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE55555),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(
        context,
      ).pop(LoanDetailResult(record: _record, deleted: true));
    }
  }

  void _markReturned() {
    setState(() => _record = _record.copyWith(status: LoanStatus.returned));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật trạng thái Đã trả.')),
    );
  }

  void _close() {
    Navigator.of(context).pop(LoanDetailResult(record: _record));
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _record.isOverdue
        ? 'Quá hạn'
        : _record.status == LoanStatus.returned
        ? 'Đã trả'
        : 'Đang mượn';
    final statusColor = _record.isOverdue
        ? const Color(0xFFE55555)
        : _record.status == LoanStatus.returned
        ? const Color(0xFF2F9B69)
        : const Color(0xFF3157D5);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Chi tiết lượt mượn'),
          actions: [
            IconButton(
              tooltip: 'Sửa',
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Xóa',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        bottomNavigationBar: _record.status == LoanStatus.borrowing
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton.icon(
                    onPressed: _markReturned,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Đánh dấu đã trả'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ),
              )
            : null,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 260,
                child: _record.imageUrl == null || _record.imageUrl!.isEmpty
                    ? const ColoredBox(
                        color: Color(0xFFE9EDF8),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 76,
                          color: Color(0xFF6F7A96),
                        ),
                      )
                    : Image.network(
                        _record.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFFE9EDF8),
                          child: Icon(Icons.broken_image_outlined, size: 64),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _record.itemName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EF)),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Người mượn',
                    value: _record.borrowerName,
                  ),
                  const Divider(height: 28),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày mượn',
                    value: formatDate(_record.borrowDate),
                  ),
                  const Divider(height: 28),
                  _InfoRow(
                    icon: Icons.event_available_outlined,
                    label: 'Hạn trả',
                    value: formatDate(_record.dueDate),
                  ),
                  if (_record.note.isNotEmpty) ...[
                    const Divider(height: 28),
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      label: 'Ghi chú',
                      value: _record.note,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF3157D5)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF737B91), fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
