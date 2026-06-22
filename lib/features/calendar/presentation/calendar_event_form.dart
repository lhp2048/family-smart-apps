import 'package:flutter/material.dart';

import '../../../core/utils/biz_date.dart';
import '../models/calendar_models.dart';

Future<FamilyEventItem?> showCalendarEventForm(
  BuildContext context, {
  required String bizDate,
  String eventType = 'plan',
  FamilyEventItem? existing,
}) {
  return showModalBottomSheet<FamilyEventItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: CalendarEventFormSheet(
        bizDate: bizDate,
        initialType: existing?.eventType ?? eventType,
        existing: existing,
      ),
    ),
  );
}

class CalendarEventFormSheet extends StatefulWidget {
  const CalendarEventFormSheet({
    super.key,
    required this.bizDate,
    required this.initialType,
    this.existing,
  });

  final String bizDate;
  final String initialType;
  final FamilyEventItem? existing;

  @override
  State<CalendarEventFormSheet> createState() => _CalendarEventFormSheetState();
}

class _CalendarEventFormSheetState extends State<CalendarEventFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _timeCtrl;
  late String _eventType;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
    _timeCtrl = TextEditingController(
      text: widget.existing?.remindAt ??
          widget.existing?.startAt ??
          '',
    );
    _eventType = widget.initialType;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写标题')),
      );
      return;
    }
    final eventId = widget.existing?.eventId ??
        'evt-${DateTime.now().millisecondsSinceEpoch}';
    final timeVal = _timeCtrl.text.trim();
    Navigator.pop(
      context,
      FamilyEventItem(
        eventId: eventId,
        eventType: _eventType,
        bizDate: widget.bizDate,
        title: title,
        content: _contentCtrl.text.trim(),
        status: widget.existing?.status ?? 'pending',
        startAt: _eventType == 'itinerary' && timeVal.isNotEmpty
            ? timeVal
            : widget.existing?.startAt,
        remindAt: _eventType == 'reminder' && timeVal.isNotEmpty
            ? timeVal
            : widget.existing?.remindAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? '编辑事件' : '新增事件',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.bizDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'itinerary', label: Text('行程')),
                ButtonSegment(value: 'plan', label: Text('计划')),
                ButtonSegment(value: 'reminder', label: Text('提醒')),
              ],
              selected: {_eventType},
              onSelectionChanged: (s) {
                setState(() => _eventType = s.first);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            if (_eventType != 'plan') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _timeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _eventType == 'reminder' ? '提醒时间' : '开始时间',
                  hintText: formatBizDate(DateTime.now()),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: Text(isEdit ? '保存' : '创建'),
            ),
          ],
        ),
      ),
    );
  }
}
