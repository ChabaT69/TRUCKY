library dummy_table_calendar;

import 'package:flutter/material.dart';

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class CalendarStyle {
  final BoxDecoration? todayDecoration;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? markerDecoration;

  const CalendarStyle({
    this.todayDecoration,
    this.selectedDecoration,
    this.markerDecoration,
  });
}

class TableCalendar<T> extends StatelessWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final bool Function(DateTime, DateTime) selectedDayPredicate;
  final List<T> Function(DateTime) eventLoader;
  final void Function(DateTime, DateTime) onDaySelected;
  final CalendarStyle calendarStyle;
  final List<T> eventsParam;

  const TableCalendar({
    Key? key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDayPredicate,
    required this.eventLoader,
    required this.onDaySelected,
    required this.calendarStyle,
    required this.eventsParam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      child: Center(child: Text("Dummy TableCalendar")),
    );
  }
}
