import 'package:flutter/material.dart';

import '../models/loan_record.dart';

class LoanFormScreen extends StatefulWidget {
  const LoanFormScreen({super.key, this.record});

  final LoanRecord? record;

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _itemController;
  late final TextEditingController _borrowerController;
  late final TextEditingController _noteController;
  late final TextEditingController _imageUrlController;
  late DateTime _borrowDate;
  late DateTime _dueDate;
  late LoanStatus _status;

  bool get _isEditing => widget.record != null;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    final now = DateTime.now();
    _itemController = TextEditingController(text: record?.itemName ?? '');
    _borrowerController = TextEditingController(
      text: record?.borrowerName ?? '',
    );
    _noteController = TextEditingController(text: record?.note ?? '');
    _imageUrlController = TextEditingController(text: record?.imageUrl ?? '');
    _borrowDate = record?.borrowDate ?? DateTime(now.year, now.month, now.day);
    _dueDate = record?.dueDate ?? _borrowDate.add(const Duration(days: 7));
    _status = record?.status ?? LoanStatus.borrowing;
  }

  @override
  void dispose() {
    _itemController.dispose();
    _borrowerController.dispose();
    _noteController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isBorrowDate}) async {
    _dismissKeyboard();
    final currentDate = isBorrowDate ? _borrowDate : _dueDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    setState(() {
      if (isBorrowDate) {
        _borrowDate = selected;
        if (_dueDate.isBefore(_borrowDate)) {
          _dueDate = _borrowDate;
        }
      } else {
        _dueDate = selected;
      }
    });
  }

  void _save() {
    _dismissKeyboard();
    if (!_formKey.currentState!.validate()) return;

    if (_dueDate.isBefore(_borrowDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hạn trả phải bằng hoặc sau ngày mượn.')),
      );
      return;
    }

    final record = LoanRecord(
      id: widget.record?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      itemName: _itemController.text.trim(),
      borrowerName: _borrowerController.text.trim(),
      borrowDate: _borrowDate,
      dueDate: _dueDate,
      status: _status,
      note: _noteController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
    );

    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa lượt mượn' : 'Thêm lượt mượn'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm lượt mượn'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _ImagePreview(imageUrl: _imageUrlController.text.trim()),
              const SizedBox(height: 14),
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                onTapOutside: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(
                  labelText: 'Đường dẫn ảnh (URL)',
                  hintText: 'https://example.com/anh.jpg',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final uri = Uri.tryParse(text);
                  if (uri == null ||
                      !uri.hasAuthority ||
                      (uri.scheme != 'http' && uri.scheme != 'https')) {
                    return 'Vui lòng nhập đường dẫn ảnh http hoặc https';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              const _FieldLabel('Thông tin món đồ'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itemController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                autocorrect: true,
                enableSuggestions: true,
                onTapOutside: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(
                  labelText: 'Tên món đồ *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập tên món đồ'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _borrowerController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autocorrect: true,
                enableSuggestions: true,
                onTapOutside: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(
                  labelText: 'Người mượn *',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập tên người mượn'
                    : null,
              ),
              const SizedBox(height: 22),
              const _FieldLabel('Thời gian'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Ngày mượn',
                      value: formatDate(_borrowDate),
                      onTap: () => _selectDate(isBorrowDate: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Hạn trả',
                      value: formatDate(_dueDate),
                      onTap: () => _selectDate(isBorrowDate: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _FieldLabel('Trạng thái'),
              const SizedBox(height: 8),
              DropdownButtonFormField<LoanStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.fact_check_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: LoanStatus.borrowing,
                    child: Text('Đang mượn'),
                  ),
                  DropdownMenuItem(
                    value: LoanStatus.returned,
                    child: Text('Đã trả'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 22),
              const _FieldLabel('Ghi chú'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                autocorrect: true,
                enableSuggestions: true,
                onTapOutside: (_) => _dismissKeyboard(),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: Có kèm dây nguồn, tình trạng còn mới...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE1EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 52, color: Color(0xFF3157D5)),
                SizedBox(height: 10),
                Text(
                  'Nhập đường dẫn ảnh bên dưới',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text('Ảnh sẽ được xem trước tại đây'),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FilledButton.tonalIcon(
                    onPressed: null,
                    icon: const Icon(Icons.link_rounded),
                    label: const Text('Ảnh từ URL'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
