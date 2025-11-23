import 'package:flutter/material.dart';
import 'package:netconnect/models/contact.dart';
import 'package:netconnect/models/event.dart';
import 'package:netconnect/provider/data_provider.dart';
import 'package:netconnect/widgets/contact_dialog.dart';
import 'package:provider/provider.dart';

class PersonDetailsDialog extends StatelessWidget {
  final Contact contact;
  final List<Event> events;

  const PersonDetailsDialog({
    super.key,
    required this.contact,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'avatar_dialog_${contact.id}',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: contact.avatarUrl != null
                          ? NetworkImage(contact.avatarUrl!)
                          : null,
                      child: contact.avatarUrl == null
                          ? Text(
                              contact.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32),
                            )
                          : null,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ContactDialog(
                            contact: contact,
                            availableEvents: provider.events,
                            onSave: (updatedContact) async {
                              try {
                                await provider.updateContact(updatedContact);
                                if (context.mounted)
                                  Navigator.pop(context); // Close ContactDialog
                                if (context.mounted)
                                  Navigator.pop(
                                    context,
                                  ); // Close PersonDetailsDialog
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update: $e'),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Contact'),
                            content: const Text(
                              'Are you sure you want to delete this contact?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await provider.deleteContact(contact.id);
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete: $e')),
                            );
                          }
                        }
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              contact.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${contact.role} @ ${contact.company}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (contact.remarks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                contact.remarks,
                style: const TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Attended Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: contact.eventIds.map((eid) {
                    final evt = events.firstWhere(
                      (e) => e.id == eid,
                      orElse: () => Event(id: '', title: 'Unknown', date: ''),
                    );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(evt.title),
                      subtitle: Text(evt.date),
                      // trailing: const Icon(Icons.chevron_right),
                      // onTap: () {
                      //   // TODO: Show Event Details Dialog?
                      //   // Or navigate? User prefers minimal screen changing.
                      //   // Let's just show the info here or allow navigating to calendar.
                      //   Navigator.pop(context);
                      //   provider.navigateToEvents(evt.id);
                      // },
                      // User wants event details dialog available.
                      onTap: () {
                        Navigator.pop(context);
                        provider.navigateToEvents(evt.id);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
