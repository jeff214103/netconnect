import 'package:flutter/material.dart';
import 'package:netconnect/models/contact.dart';
import 'package:netconnect/models/event.dart';
import 'package:netconnect/services/google_sheet_service.dart';
import 'package:netconnect/utils/google_sign_in.dart';

class DataProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  List<Event> _events = [];
  bool _isLoading = false;
  bool _isAuthenticated = false;

  List<Contact> get contacts => _contacts;
  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _isAuthenticated;

  // Navigation & Filter State
  int _selectedIndex = 0;
  String? _selectedEventId;
  String? _highlightEventId;

  int get selectedIndex => _selectedIndex;
  String? get selectedEventId => _selectedEventId;

  String? get highlightEventId => _highlightEventId;
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void navigateToPeople(String eventId) {
    _selectedEventId = eventId;
    _selectedIndex = 1; // People tab
    notifyListeners();
  }

  void navigateToEvents(String eventId) {
    _highlightEventId = eventId;
    _selectedIndex = 0; // Events tab

    // Also set the selected date
    final event = _events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => Event(id: '', title: '', date: ''),
    );
    if (event.id.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(event.date);
      } catch (e) {
        print('Error parsing date for navigation: $e');
      }
    }
    notifyListeners();
  }

  void clearEventFilter() {
    _selectedEventId = null;
    notifyListeners();
  }

  void clearEventHighlight() {
    _highlightEventId = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final account = GoogleSignInHelper.googleSignIn.currentUser;
    if (account != null) {
      _isAuthenticated = true;
      notifyListeners();
      await fetchData();
    } else {
      // Try silent sign in
      final account = await GoogleSignInHelper.signInSilently();
      if (account != null) {
        _isAuthenticated = true;
        notifyListeners();
        await fetchData();
      }
    }
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> signIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final account = await GoogleSignInHelper.signIn();
      if (account != null) {
        _isAuthenticated = true;
        await fetchData();
      } else {
        _errorMessage = "Sign in cancelled.";
      }
    } catch (e) {
      _errorMessage = "Sign in failed: $e";
      print(_errorMessage);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await GoogleSignInHelper.signOut();
    _isAuthenticated = false;
    _contacts = [];
    _events = [];
    notifyListeners();
  }

  Future<void> fetchData() async {
    if (!_isAuthenticated) return;
    _isLoading = true;
    notifyListeners();
    try {
      print('Fetching data...');
      _contacts = await GoogleSheetService.getContacts();
      print('Contacts fetched: ${_contacts.length}');
      _events = await GoogleSheetService.getEvents();
      print('Events fetched: ${_events.length}');
    } catch (e, stackTrace) {
      print('Error fetching data: $e');
      print(stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(Contact contact) async {
    try {
      _contacts.add(contact);
      notifyListeners();
      await GoogleSheetService.syncContacts(_contacts);
      print('Contact added and synced: ${contact.name}');
    } catch (e) {
      print('Error adding contact: $e');
      _contacts.remove(contact); // Revert
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteContact(String id) async {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final contact = _contacts[index];

    try {
      _contacts.removeAt(index);
      notifyListeners();
      await GoogleSheetService.syncContacts(_contacts);
      print('Contact deleted and synced: ${contact.name}');
    } catch (e) {
      print('Error deleting contact: $e');
      _contacts.insert(index, contact); // Revert
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateContact(Contact contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index == -1) return;
    final oldContact = _contacts[index];

    try {
      _contacts[index] = contact;
      notifyListeners();
      await GoogleSheetService.syncContacts(_contacts);
      print('Contact updated and synced: ${contact.name}');
    } catch (e) {
      print('Error updating contact: $e');
      _contacts[index] = oldContact; // Revert
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      _events.add(event);
      notifyListeners();
      await GoogleSheetService.syncEvents(_events);
      print('Event added and synced: ${event.title}');
    } catch (e) {
      print('Error adding event: $e');
      _events.remove(event); // Revert
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final event = _events[index];

    try {
      _events.removeAt(index);
      notifyListeners();
      await GoogleSheetService.syncEvents(_events);
      print('Event deleted and synced: ${event.title}');
    } catch (e) {
      print('Error deleting event: $e');
      _events.insert(index, event); // Revert
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) return;
    final oldEvent = _events[index];

    try {
      _events[index] = event;
      notifyListeners();
      await GoogleSheetService.syncEvents(_events);
      print('Event updated and synced: ${event.title}');
    } catch (e) {
      print('Error updating event: $e');
      _events[index] = oldEvent; // Revert
      notifyListeners();
      rethrow;
    }
  }
}
