import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:netconnect/models/contact.dart';
import 'package:netconnect/models/event.dart';

class GeminiService {
  static FirebaseAI getFirebaseAI() {
    return FirebaseAI.googleAI(appCheck: FirebaseAppCheck.instance);
  }

  static Future<String> searchNaturalLanguage({
    required String query,
    required List<Contact> contacts,
    required List<Event> events,
    String modelName = 'gemini-2.0-flash',
  }) async {
    final model = getFirebaseAI().generativeModel(model: modelName);

    // Prepare context
    final contextData = {
      'events': events
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'date': e.date,
              'loc': e.location,
            },
          )
          .toList(),
      'contacts': contacts
          .map(
            (c) => {
              'name': c.name,
              'company': c.company,
              'role': c.role,
              'remarks': c.remarks,
              'met_at_event_ids': c.eventIds,
            },
          )
          .toList(),
    };

    final prompt =
        '''
      You are a personal networking assistant. I have a database of contacts and events.
      
      Current Database:
      $contextData

      User Question: "$query"

      Answer the question based ONLY on the database provided. 
      If the user asks about a specific person, detail where I met them (cross-reference event IDs).
      If looking for people by company/role, list them.
      Keep the tone professional and concise. Format the output in clean Markdown.
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "No response generated.";
    } catch (e) {
      print("Gemini Error: $e");
      return "Error connecting to AI Service: $e";
    }
  }

  static Future<String> checkDuplicates({
    required List<Contact> contacts,
    String modelName = 'gemini-1.5-flash',
  }) async {
    final model = getFirebaseAI().generativeModel(model: modelName);

    final contactList = contacts
        .map((c) => '${c.name} (${c.company})')
        .join(', ');

    final prompt =
        '''
      Analyze this list of networking contacts for potential duplicates (e.g. fuzzy name matching, same person different company spelling):
      $contactList

      Return a bulleted list of potential duplicates found. If none, say "No likely duplicates found."
      Keep it very short.
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "No response.";
    } catch (e) {
      print("Gemini Error: $e");
      return "Error checking duplicates: $e";
    }
  }
}
