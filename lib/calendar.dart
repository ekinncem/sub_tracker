// Takvim Ekranı
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/subscription_provider.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Abonelik Takvimi')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                // Abonelik yenileme tarihlerini işaretleme
                eventLoader: (day) {
                  return provider.subscriptions
                    .where((sub) => isSameDay(sub.renewalDate, day))
                    .toList();
                },
              ),
              Expanded(
                child: _buildRenewalList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRenewalList(SubscriptionProvider provider) {
    final renewalSubscriptions = provider.subscriptions
      .where((sub) => isSameDay(sub.renewalDate, _selectedDay))
      .toList();

    return ListView.builder(
      itemCount: renewalSubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = renewalSubscriptions[index];
        return ListTile(
          title: Text(subscription.name),
          subtitle: Text('${subscription.price} TL - ${subscription.category}'),
          trailing: Text('Yenileme: ${subscription.renewalDate.day}/${subscription.renewalDate.month}/${subscription.renewalDate.year}'),
        );
      },
    );
  }
}