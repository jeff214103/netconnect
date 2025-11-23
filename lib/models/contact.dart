class Contact {
  final String id;
  final String name;
  final String company;
  final String role;
  final String remarks;
  final List<String> eventIds;
  final String? avatarUrl;

  Contact({
    required this.id,
    required this.name,
    this.company = '',
    this.role = '',
    this.remarks = '',
    this.eventIds = const [],
    this.avatarUrl,
  });

  // Generate a short ID with prefix
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Take last 8 digits and convert to base36 for shorter representation
    final shortId = (timestamp % 100000000).toRadixString(36).toUpperCase();
    return 'C-$shortId';
  }

  static List<String> get headers => [
    'ID',
    'Name',
    'Company',
    'Role',
    'Remarks',
    'EventIDs', // Comma separated
    'AvatarURL',
  ];

  List<String> toSheetRow() {
    return [
      id,
      name,
      company,
      role,
      remarks,
      eventIds.join(';'), // Use semicolon to avoid conflicts
      avatarUrl ?? '',
    ];
  }

  factory Contact.fromSheetRow(List<Object?> row) {
    return Contact(
      id: row.length > 0 ? row[0].toString() : '',
      name: row.length > 1 ? row[1].toString() : '',
      company: row.length > 2 ? row[2].toString() : '',
      role: row.length > 3 ? row[3].toString() : '',
      remarks: row.length > 4 ? row[4].toString() : '',
      eventIds: row.length > 5
          ? row[5]
                .toString()
                .split(';')
                .where((e) => e.trim().isNotEmpty)
                .toList()
          : [],
      avatarUrl: row.length > 6 && row[6].toString().isNotEmpty
          ? row[6].toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'role': role,
      'remarks': remarks,
      'eventIds': eventIds,
      'avatarUrl': avatarUrl,
    };
  }
}
