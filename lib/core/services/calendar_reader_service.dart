import 'package:device_calendar/device_calendar.dart';

class CalendarReaderService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  // Retrieve all calendars on the device
  Future<List<Calendar>> retrieveCalendars() async {
    // Check and request permissions
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.data == null) {
      throw Exception('no permission granted');
    }
    if (!permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.data!) throw Exception('no permission granted');
    }

    // Retrieve calendars
    final calendarsResult =
        (await _deviceCalendarPlugin.retrieveCalendars()).data;
    return calendarsResult ?? [];
  }

  // Retrieve events from a specific calendar
  Future<List<Event>> retrieveCalendarEvents(Calendar calendar,
      {DateTime? startDate, DateTime? endDate}) async {
    // If no dates provided, default to current year
    startDate ??= DateTime(DateTime.now().year, 1, 1);
    endDate ??= DateTime(DateTime.now().year, 12, 31);

    // Retrieve events within the specified date range
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: startDate,
          endDate: endDate,
        ));
    return eventsResult.data ?? [];
  }

  // Add a method to filter events
  Future<List<Event>> filterEventsByTitle(
      Calendar calendar, String titleQuery) async {
    final allEvents = await retrieveCalendarEvents(calendar);
    return allEvents
        .where((event) =>
            event.title?.toLowerCase().contains(titleQuery.toLowerCase()) ??
            false)
        .toList();
  }
}
