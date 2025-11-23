import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:netconnect/models/contact.dart';
import 'package:netconnect/models/event.dart';
import 'package:netconnect/utils/google_sign_in.dart';

class GoogleSheetService {
  static const String _spreadsheetName = 'NetConnect Data';
  static const String _contactsSheetTitle = 'Contacts';
  static const String _eventsSheetTitle = 'Events';

  static Future<String> getSpreadsheetId() async {
    final googleAuth = await GoogleSignInHelper.getAuthenticatedClient();
    final driveApi = drive.DriveApi(googleAuth);
    final sheetsApi = sheets.SheetsApi(googleAuth);

    // List files with spreadsheet mime type
    final files = await driveApi.files.list(
      q: "mimeType = 'application/vnd.google-apps.spreadsheet' and name = '$_spreadsheetName' and trashed = false",
    );

    if (files.files != null && files.files!.isNotEmpty) {
      return files.files!.first.id!;
    }

    // Create spreadsheet
    final spreadsheet = await sheetsApi.spreadsheets.create(
      sheets.Spreadsheet()
        ..properties = sheets.SpreadsheetProperties(title: _spreadsheetName),
    );

    return spreadsheet.spreadsheetId!;
  }

  static const String _settingsSheetTitle = 'Settings';

  static Future<void> _ensureSheetExists(
      sheets.SheetsApi sheetsApi, String spreadsheetId, String title) async {
    final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
    bool exists =
        spreadsheet.sheets?.any((s) => s.properties?.title == title) ?? false;

    if (!exists) {
      await sheetsApi.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: [
          sheets.Request(
            addSheet: sheets.AddSheetRequest(
              properties: sheets.SheetProperties(title: title),
            ),
          )
        ]),
        spreadsheetId,
      );
    }
  }

  static Future<Map<String, String>> getSettings() async {
    final googleAuth = await GoogleSignInHelper.getAuthenticatedClient();
    final sheetsApi = sheets.SheetsApi(googleAuth);
    final spreadsheetId = await getSpreadsheetId();

    await _ensureSheetExists(sheetsApi, spreadsheetId, _settingsSheetTitle);

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      '$_settingsSheetTitle!A:B',
    );

    final settings = <String, String>{};
    if (response.values != null) {
      for (var row in response.values!) {
        if (row.length >= 2) {
          settings[row[0].toString()] = row[1].toString();
        }
      }
    }
    return settings;
  }

  static Future<void> updateSetting(String key, String value) async {
    final googleAuth = await GoogleSignInHelper.getAuthenticatedClient();
    final sheetsApi = sheets.SheetsApi(googleAuth);
    final spreadsheetId = await getSpreadsheetId();

    await _ensureSheetExists(sheetsApi, spreadsheetId, _settingsSheetTitle);

    // Read all settings to find the row
    final currentSettings = await getSettings();
    final keys = currentSettings.keys.toList();
    int rowIndex = keys.indexOf(key);

    if (rowIndex != -1) {
      // Update existing
      await sheetsApi.spreadsheets.values.update(
        sheets.ValueRange(values: [
          [key, value]
        ]),
        spreadsheetId,
        '$_settingsSheetTitle!A${rowIndex + 1}',
        valueInputOption: 'USER_ENTERED',
      );
    } else {
      // Append new
      await sheetsApi.spreadsheets.values.append(
        sheets.ValueRange(values: [
          [key, value]
        ]),
        spreadsheetId,
        '$_settingsSheetTitle!A1',
        valueInputOption: 'USER_ENTERED',
      );
    }
  }

  static Future<void> syncContacts(List<Contact> contacts) async {
    final googleAuth = await GoogleSignInHelper.getAuthenticatedClient();
    final sheetsApi = sheets.SheetsApi(googleAuth);
    final spreadsheetId = await getSpreadsheetId();

    await _ensureSheetExists(sheetsApi, spreadsheetId, _contactsSheetTitle);

    // Clear existing data first to handle deletions
    await sheetsApi.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      spreadsheetId,
      '$_contactsSheetTitle!A2:Z',
    );

    // Prepare data
    final values = [
      Contact.headers,
      ...contacts.map((c) => c.toSheetRow()),
    ];

    // Write new data
    await sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: values),
      spreadsheetId,
      '$_contactsSheetTitle!A1',
      valueInputOption: 'USER_ENTERED',
    );
  }

  static Future<List<Contact>> getContacts() async {
    final googleAuth = await GoogleSignInHelper.getAuthenticatedClient();
    final sheetsApi = sheets.SheetsApi(googleAuth);
    final spreadsheetId = await getSpreadsheetId();

    await _ensureSheetExists(sheetsApi, spreadsheetId, _contactsSheetTitle);

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      '$_contactsSheetTitle!A2:Z',
    );

    if (response.values == null) return [];

    return response.values!.map((row) => Contact.fromSheetRow(row)).toList();
  }

  static Future<void> syncEvents(List<Event> events) async {
    final googleAuth = await GoogleSignInHelper.getAuthenticatedClient();
    final sheetsApi = sheets.SheetsApi(googleAuth);
    final spreadsheetId = await getSpreadsheetId();

    await _ensureSheetExists(sheetsApi, spreadsheetId, _eventsSheetTitle);

    // Clear existing data first
    await sheetsApi.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      spreadsheetId,
      '$_eventsSheetTitle!A2:Z',
    );

    // Prepare data
    final values = [
      Event.headers,
      ...events.map((e) => e.toSheetRow()),
    ];

    // Write new data
    await sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: values),
      spreadsheetId,
      '$_eventsSheetTitle!A1',
      valueInputOption: 'USER_ENTERED',
    );
  }

  static Future<List<Event>> getEvents() async {
    final googleAuth = await GoogleSignInHelper.getAuthenticatedClient();
    final sheetsApi = sheets.SheetsApi(googleAuth);
    final spreadsheetId = await getSpreadsheetId();

    await _ensureSheetExists(sheetsApi, spreadsheetId, _eventsSheetTitle);

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      '$_eventsSheetTitle!A2:Z',
    );

    if (response.values == null) return [];

    return response.values!.map((row) => Event.fromSheetRow(row)).toList();
  }
}
