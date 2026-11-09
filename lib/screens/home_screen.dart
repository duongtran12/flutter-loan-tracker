import 'package:flutter/material.dart';

import '../models/loan_record.dart';
import '../widgets/loan_card.dart';
import 'loan_detail_screen.dart';
import 'loan_form_screen.dart';

enum LoanFilter { all, borrowing, returned, overdue }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  LoanFilter _filter = LoanFilter.all;

  final List<LoanRecord> _records = [
    LoanRecord(
      id: 'sample-1',
      itemName: 'Sạc laptop Acer 135W',
      borrowerName: 'Minh',
      borrowDate: DateTime(2026, 11, 5),
      dueDate: DateTime(2026, 11, 12),
      status: LoanStatus.borrowing,
      note: 'Có kèm dây nguồn.',
    ),
    LoanRecord(
      id: 'sample-2',
      itemName: 'Sách Lập trình Flutter',
      borrowerName: 'Huy',
      borrowDate: DateTime(2026, 10, 25),
      dueDate: DateTime(2026, 11, 2),
      status: LoanStatus.returned,
      note: 'Sách còn nguyên vẹn.',
    ),
  ];

  List<LoanRecord> get _visibleRecords {
    final keyword = _searchController.text.trim().toLowerCase();

    return _records.where((record) {
      final matchesSearch =
          keyword.isEmpty ||
          record.itemName.toLowerCase().contains(keyword) ||
          record.borrowerName.toLowerCase().contains(keyword);

      final matchesFilter = switch (_filter) {
        LoanFilter.all => true,
        LoanFilter.borrowing =>
          record.status == LoanStatus.borrowing && !record.isOverdue,
        LoanFilter.returned => record.status == LoanStatus.returned,
        LoanFilter.overdue => record.isOverdue,
      };

      return matchesSearch && matchesFilter;
    }).toList()..sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
  }

  int get _borrowingCount =>
      _records.where((record) => record.status == LoanStatus.borrowing).length;

  int get _overdueCount => _records.where((record) => record.isOverdue).length;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addRecord() async {
    _dismissKeyboard();
    final record = await Navigator.of(context).push<LoanRecord>(
      MaterialPageRoute(builder: (_) => const LoanFormScreen()),
    );

    if (record != null) {
      setState(() => _records.add(record));
    }
  }

  Future<void> _openDetail(LoanRecord record) async {
    final result = await Navigator.of(context).push<LoanDetailResult>(
      MaterialPageRoute(builder: (_) => LoanDetailScreen(record: record)),
    );

    if (result == null) return;

    setState(() {
      final index = _records.indexWhere((item) => item.id == record.id);
      if (index == -1) return;

      if (result.deleted) {
        _records.removeAt(index);
      } else {
        _records[index] = result.record;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = _visibleRecords;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sổ mượn đồ', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'Quản lý đồ dùng của bạn',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm lượt mượn'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Đang mượn',
                        value: _borrowingCount.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFF3157D5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Quá hạn',
                        value: _overdueCount.toString(),
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFFE55555),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  autocorrect: true,
                  enableSuggestions: true,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _dismissKeyboard(),
                  onTapOutside: (_) => _dismissKeyboard(),
                  decoration: const InputDecoration(
                    hintText: 'Tìm món đồ hoặc người mượn',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(
                height: 62,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Tất cả', LoanFilter.all),
                    _filterChip('Đang mượn', LoanFilter.borrowing),
                    _filterChip('Đã trả', LoanFilter.returned),
                    _filterChip('Quá hạn', LoanFilter.overdue),
                  ],
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? _EmptyState(onAdd: _addRecord)
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: records.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return LoanCard(
                            record: record,
                            onTap: () => _openDetail(record),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, LoanFilter value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) {
          _dismissKeyboard();
          setState(() => _filter = value);
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E9F1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: Color(0xFF9CA4BA),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lượt mượn phù hợp',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm lượt mượn đầu tiên hoặc thay đổi bộ lọc.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
