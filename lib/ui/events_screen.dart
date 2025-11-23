import 'package:flutter/material.dart';
import 'package:netconnect/models/event.dart';
import 'package:netconnect/provider/data_provider.dart';
import 'package:netconnect/widgets/event_dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:netconnect/models/contact.dart';
import 'package:netconnect/ui/dialogs/event_details_dialog.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Initialize with today or provider state if we want to be fancy,
    // but the key is updating it when the widget rebuilds with a new highlight.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We rely on provider state now, so no need for complex sync logic here
    // unless we want to sync focused day with selected day initially.
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final events = provider.events;

    // Auto-switch to list view if there is a highlight event
    // Auto-select day if there is a highlight event

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Events',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) => EventDialog(
                              onSave: (event) async {
                                try {
                                  await provider.addEvent(event);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to add event: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCalendarView(events, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<Event> events, DataProvider provider) {
    final selectedDay = provider.selectedDate;

    // Sync focused day if selected day changes externally
    if (selectedDay != null && !isSameDay(_focusedDay, selectedDay)) {
      if (selectedDay.month != _focusedDay.month ||
          selectedDay.year != _focusedDay.year) {
        _focusedDay = selectedDay;
      }
    }

    final selectedEvents = selectedDay == null
        ? []
        : events.where((event) {
            try {
              final eventDate = DateTime.parse(event.date);
              return isSameDay(eventDate, selectedDay);
            } catch (e) {
              return false;
            }
          }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _focusedDay = focused;
                  });
                  provider.setSelectedDate(selected);
                },
                eventLoader: (day) {
                  return events.where((event) {
                    try {
                      final eventDate = DateTime.parse(event.date);
                      return isSameDay(eventDate, day);
                    } catch (e) {
                      return false;
                    }
                  }).toList();
                },
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        if (selectedDay != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Events on ${DateFormat('MMM d, y').format(selectedDay)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (selectedEvents.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No events for this day.'),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final event = selectedEvents[index];
                final attendees = provider.contacts
                    .where((c) => c.eventIds.contains(event.id))
                    .toList();
                final isHighlighted = event.id == provider.highlightEventId;

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => EventDetailsDialog(event: event),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isHighlighted ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHighlighted
                            ? Colors.blue
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${event.location} • ${attendees.length} attendees',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                );
              }, childCount: selectedEvents.length),
            ),
        ] else
          const SliverToBoxAdapter(
            child: Center(child: Text('Select a date to view events.')),
          ),
      ],
    );
  }
}
