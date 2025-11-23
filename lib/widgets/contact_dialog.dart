import 'package:flutter/material.dart';
import 'package:netconnect/models/contact.dart';
import 'package:netconnect/models/event.dart';

class ContactDialog extends StatefulWidget {
  final Function(Contact) onSave;
  final List<Event> availableEvents;
  final Contact? contact;

  const ContactDialog({
    super.key,
    required this.onSave,
    required this.availableEvents,
    this.contact,
  });

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _remarksController = TextEditingController();
  final List<String> _selectedEventIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _companyController.text = widget.contact!.company;
      _roleController.text = widget.contact!.role;
      _remarksController.text = widget.contact!.remarks;
      _selectedEventIds.addAll(widget.contact!.eventIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'New Contact' : 'Edit Contact'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(labelText: 'Company'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _roleController,
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _remarksController,
                  decoration: const InputDecoration(labelText: 'Remarks'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Met At (Select Events)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.availableEvents.isEmpty
                      ? const Center(child: Text('No events available'))
                      : ListView.builder(
                          itemCount: widget.availableEvents.length,
                          itemBuilder: (context, index) {
                            final event = widget.availableEvents[index];
                            return CheckboxListTile(
                              title: Text(event.title),
                              subtitle: Text(event.date),
                              value: _selectedEventIds.contains(event.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedEventIds.add(event.id);
                                  } else {
                                    _selectedEventIds.remove(event.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final contact = Contact(
                id: widget.contact?.id ?? Contact.generateId(),
                name: _nameController.text,
                company: _companyController.text,
                role: _roleController.text,
                remarks: _remarksController.text,
                eventIds: _selectedEventIds,
                avatarUrl:
                    widget.contact?.avatarUrl ??
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nameController.text)}&background=random',
              );
              widget.onSave(contact);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
