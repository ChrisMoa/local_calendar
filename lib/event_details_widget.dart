import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsWidget extends StatelessWidget {
  final Event event;

  const EventDetailsWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              event.title ?? 'Untitled Event',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
            ),
            const SizedBox(height: 12),

            // Date and Time
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: _formatDate(event.start),
            ),
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Time',
              value: '${_formatTime(event.start)} - ${_formatTime(event.end)}',
            ),

            // Location (if available)
            if (event.location != null && event.location!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'Location',
                value: event.location!,
              ),

            // Description (if available)
            if (event.description != null && event.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  event.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            // Additional Event Attributes
            _buildAdditionalDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails(BuildContext context) {
    // Collect additional details
    final details = <String>[];

    if (event.allDay ?? false) {
      details.add('All Day Event');
    }

    if (event.recurrenceRule != null) {
      details.add('Recurring Event');
    }

    if (details.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: details.map((detail) {
            return Chip(
              label: Text(
                detail,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.blue[50],
            );
          }).toList(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown Date';
    return DateFormat('EEEE, MMMM d, yyyy').format(dateTime.toLocal());
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown Time';
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }
}
