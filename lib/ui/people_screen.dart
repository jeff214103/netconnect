import 'package:flutter/material.dart';
import 'package:netconnect/models/event.dart';
import 'package:netconnect/provider/data_provider.dart';
import 'package:netconnect/ui/dialogs/person_details_dialog.dart';
import 'package:netconnect/widgets/contact_dialog.dart';

import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final allContacts = provider.contacts;
    final events = provider.events;

    final selectedEventId = provider.selectedEventId;
    var contacts = selectedEventId == null
        ? allContacts
        : allContacts
              .where((c) => c.eventIds.contains(selectedEventId))
              .toList();

    if (_searchQuery.isNotEmpty) {
      contacts = contacts.where((c) {
        final name = c.name.toLowerCase();
        final company = c.company.toLowerCase();
        final role = c.role.toLowerCase();
        return name.contains(_searchQuery) ||
            company.contains(_searchQuery) ||
            role.contains(_searchQuery);
      }).toList();
    }

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
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = MediaQuery.of(context).size.width < 600;
                if (isSmallScreen) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'People',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildAddButton(provider, events),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSearchField(),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'People',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 250),
                                child: _buildSearchField(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildAddButton(provider, events),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            if (selectedEvent != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Attendees of ${selectedEvent.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
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
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No people found matching "$_searchQuery"'
                            : 'No contacts yet.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.shadow.withOpacity(0.05),
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
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
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              evt.title,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer,
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search people...',
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildAddButton(DataProvider provider, List<Event> events) {
    return FilledButton.icon(
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
                          SnackBar(content: Text('Failed to add contact: $e')),
                        );
                      }
                    }
                  },
                ),
              );
            },
      icon: provider.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.person_add),
      label: const Text('Add Contact'),
    );
  }
}
