import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/subscription.dart';

class CalendarPage extends StatefulWidget {
  final List<Subscription> subscriptions;
  const CalendarPage({Key? key, required this.subscriptions}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  // Maps subscriptions to their dates for display in calendar
  Map<DateTime, List<Subscription>> get _events {
    Map<DateTime, List<Subscription>> events = {};
    for (var sub in widget.subscriptions) {
      final date = DateTime(
        sub.startDate.year,
        sub.startDate.month,
        sub.startDate.day,
      );
      if (events[date] == null) {
        events[date] = [sub];
      } else {
        events[date]!.add(sub);
      }
    }
    return events;
  }

  List<Subscription> _getSubscriptionsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar<Subscription>(
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getSubscriptionsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.lightBlue.shade300,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightBlue,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _getSubscriptionsForDay(_selectedDay).length,
            itemBuilder: (context, index) {
              final sub = _getSubscriptionsForDay(_selectedDay)[index];
              return ListTile(
                leading: Icon(Icons.subscriptions, color: Colors.lightBlue),
                title: Text(sub.name),
                subtitle: Text(
                  'Category: ${sub.category}\nPrice: \$${sub.price.toStringAsFixed(2)}',
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
