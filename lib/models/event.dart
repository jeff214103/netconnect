class Event {
  final String id;
  final String title;
  final String date; // ISO 8601 YYYY-MM-DD
  final String location;
  final String description;
  final String? googleEventId;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.location = '',
    this.description = '',
    this.googleEventId,
  });

  // Generate a short ID with prefix
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Take last 8 digits and convert to base36 for shorter representation
    final shortId = (timestamp % 100000000).toRadixString(36).toUpperCase();
    return 'E-$shortId';
  }

  static List<String> get headers => [
    'ID',
    'Title',
    'Date',
    'Location',
    'Description',
    'GoogleEventID',
  ];

  List<String> toSheetRow() {
    return [id, title, date, location, description, googleEventId ?? ''];
  }

  factory Event.fromSheetRow(List<Object?> row) {
    return Event(
      id: row.length > 0 ? row[0].toString() : '',
      title: row.length > 1 ? row[1].toString() : '',
      date: row.length > 2 ? row[2].toString() : '',
      location: row.length > 3 ? row[3].toString() : '',
      description: row.length > 4 ? row[4].toString() : '',
      googleEventId: row.length > 5 ? row[5].toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'location': location,
      'description': description,
      'googleEventId': googleEventId,
    };
  }
}
