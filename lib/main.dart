import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_calendar/core/services/calendar_reader_service.dart';
import 'package:local_calendar/event_details_widget.dart';

void main() {
  runApp(LocalCalendarApp());
}

class LocalCalendarApp extends StatelessWidget {
  final CalendarReaderService _calendarReaderService = CalendarReaderService();

  LocalCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarViewScreen(calendarReaderService: _calendarReaderService),
    );
  }
}

class CalendarViewScreen extends StatelessWidget {
  final CalendarReaderService calendarReaderService;

  const CalendarViewScreen({super.key, required this.calendarReaderService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Calendars')),
      body: FutureBuilder<List<Calendar>>(
        future: calendarReaderService.retrieveCalendars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No calendars found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final calendar = snapshot.data![index];
              return ExpansionTile(
                title: Text(calendar.name ?? 'Unnamed Calendar'),
                children: [
                  _buildCalendarEventsList(calendar),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCalendarEventsList(Calendar calendar) {
    return FutureBuilder<List<Event>>(
      future: calendarReaderService.retrieveCalendarEvents(calendar),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No events found');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final event = snapshot.data![index];
            return InkWell(
              onTap: () {
                // Show event details in a bottom sheet
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.7,
                    minChildSize: 0.5,
                    maxChildSize: 0.9,
                    expand: false,
                    builder: (context, scrollController) =>
                        SingleChildScrollView(
                      controller: scrollController,
                      child: EventDetailsWidget(event: event),
                    ),
                  ),
                );
              },
              child: ListTile(
                title: Text(event.title ?? 'Untitled Event'),
                subtitle: Text(
                  'Start: ${_formatDateTime(event.start)}\n'
                  'End: ${_formatDateTime(event.end)}',
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime.toLocal());
  }
}
