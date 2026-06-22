import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_product_flags.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/biz_date.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../features/dashboard/data/family_api_client.dart';
import '../../../shared/providers/calendar_ui_providers.dart';
import '../data/calendar_api_mappers.dart';
import '../data/calendar_remote_write.dart';
import '../models/calendar_models.dart';
import 'calendar_day_detail.dart';
import 'calendar_event_form.dart';

const Color _kCalAccent = Color(0xFF7986CB);

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarSelectedBizDateProvider.notifier).state =
          formatBizDate(now);
    });
  }

  String get _selectedBizDate => formatBizDate(_selectedDay);

  String get _monthKey =>
      '${_focusedDay.year.toString().padLeft(4, '0')}-${_focusedDay.month.toString().padLeft(2, '0')}';

  Future<void> _refreshCalendar() async {
    ref.read(calendarRemoteRefreshProvider.notifier).state++;
    ref.invalidate(calendarMonthAsyncProvider(_monthKey));
    ref.invalidate(calendarDayAsyncProvider(_selectedBizDate));
  }

  Future<void> _addEvent([String type = 'plan']) async {
    final item = await showCalendarEventForm(
      context,
      bizDate: _selectedBizDate,
      eventType: type,
    );
    if (item == null || !mounted) return;
    try {
      await syncCalendarEventRemote(ref, event: item);
      await _refreshCalendar();
    } on FamilyApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _editEvent(FamilyEventItem event) async {
    final item = await showCalendarEventForm(
      context,
      bizDate: event.bizDate,
      existing: event,
    );
    if (item == null || !mounted) return;
    try {
      await syncCalendarEventRemote(ref, event: item);
      await _refreshCalendar();
    } on FamilyApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _toggleEvent(FamilyEventItem event) async {
    try {
      await toggleCalendarEventDoneRemote(ref, event: event);
      await _refreshCalendar();
    } on FamilyApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _deleteEvent(FamilyEventItem event) async {
    try {
      await deleteCalendarEventRemote(ref, eventId: event.eventId);
      await _refreshCalendar();
    } on FamilyApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(calendarRemoteRefreshProvider);
    final monthAsync = ref.watch(calendarMonthAsyncProvider(_monthKey));
    final dayAsync = ref.watch(calendarDayAsyncProvider(_selectedBizDate));
    final readOnly = kEffectiveReadOnlyDataMode;

    final monthDays = monthAsync.valueOrNull?.days ?? const [];
    final indicatorsByDate = {
      for (final d in monthDays) d.bizDate: d.indicators,
    };

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      floatingActionButton: readOnly
          ? null
          : FloatingActionButton(
              onPressed: () => _addEvent(),
              backgroundColor: _kCalAccent,
              child: const Icon(Icons.add_rounded),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.calendar_month_rounded,
              title: '家庭日历',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshCalendar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _buildCalendar(indicatorsByDate),
                    const SizedBox(height: 12),
                    Text(
                      '$_selectedBizDate · ${weekdayCn(_selectedDay)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    dayAsync.when(
                      data: (bundle) => CalendarDayDetail(
                        bundle: bundle,
                        readOnly: readOnly,
                        onSectionTap: (type) {
                          final route = calendarSectionRoute(type, _selectedBizDate);
                          if (route != '/calendar') {
                            context.push(route);
                          }
                        },
                        onEventTap: readOnly ? null : _editEvent,
                        onEventToggle: readOnly ? null : _toggleEvent,
                        onEventDelete: readOnly ? null : _deleteEvent,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '加载失败：$e',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(Map<String, CalendarDayIndicators> indicatorsByDate) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: TableCalendar<void>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _format,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'en_US',
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          formatButtonTextStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(8),
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          weekendTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          selectedDecoration: const BoxDecoration(
            color: _kCalAccent,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: _kCalAccent.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final bizDate = formatBizDate(day);
            final indicators = indicatorsByDate[bizDate];
            if (indicators == null || !indicators.hasAnyData) {
              return null;
            }
            final types = indicators.activeTypes.take(4);
            return Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final t in types)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: calendarIndicatorColor(t),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
          ref.read(calendarSelectedBizDateProvider.notifier).state =
              formatBizDate(selected);
        },
        onPageChanged: (focused) {
          setState(() => _focusedDay = focused);
          ref.read(calendarFocusedMonthKeyProvider.notifier).state =
              '${focused.year.toString().padLeft(4, '0')}-${focused.month.toString().padLeft(2, '0')}';
        },
        onFormatChanged: (format) {
          setState(() => _format = format);
        },
      ),
    );
  }
}
