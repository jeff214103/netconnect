import 'package:flutter/material.dart';
import 'package:netconnect/models/event.dart';
import 'package:netconnect/provider/data_provider.dart';
import 'package:netconnect/ui/dialogs/person_details_dialog.dart';
import 'package:netconnect/widgets/contact_dialog.dart';

import 'package:provider/provider.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final allContacts = provider.contacts;
    final events = provider.events;

    final selectedEventId = provider.selectedEventId;
    final contacts = selectedEventId == null
        ? allContacts
        : allContacts
              .where((c) => c.eventIds.contains(selectedEventId))
              .toList();

    final selectedEvent = selectedEventId == null
        ? null
        : events.firstWhere(
            (e) => e.id == selectedEventId,
            orElse: () => Event(id: '', title: 'Unknown', date: ''),
          );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'People',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) => ContactDialog(
                              availableEvents: events,
                              onSave: (contact) async {
                                try {
                                  await provider.addContact(contact);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to add contact: $e',
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
                      : const Icon(Icons.person_add),
                  label: const Text('Add Contact'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedEvent != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 20, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Attendees of ${selectedEvent.title}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.blue,
                      ),
                      onPressed: () => provider.clearEventFilter(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contacts.isEmpty
                  ? const Center(child: Text('No contacts yet.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisExtent: 180,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => PersonDetailsDialog(
                                contact: contact,
                                events: events,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Hero(
                                      tag: 'avatar_${contact.id}',
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            contact.avatarUrl != null
                                            ? NetworkImage(contact.avatarUrl!)
                                            : null,
                                        child: contact.avatarUrl == null
                                            ? Text(
                                                contact.name[0].toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      contact.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${contact.role} @ ${contact.company}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      alignment: WrapAlignment.center,
                                      children: contact.eventIds.map((eid) {
                                        final evt = events.firstWhere(
                                          (e) => e.id == eid,
                                          orElse: () => Event(
                                            id: '',
                                            title: 'Unknown',
                                            date: '',
                                          ),
                                        );
                                        return GestureDetector(
                                          onTap: () {
                                            provider.navigateToEvents(evt.id);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              evt.title,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
