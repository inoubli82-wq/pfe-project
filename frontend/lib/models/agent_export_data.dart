class AgentExportData {
  final int? id;
  final String trailerNumber;
  final DateTime date;
  final String clientName;
  final String country;
  final String? transporter;
  final int barsCount;
  final int singlesCount;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgentExportData({
    this.id,
    required this.trailerNumber,
    required this.date,
    required this.clientName,
    required this.country,
    this.transporter,
    this.barsCount = 0,
    this.singlesCount = 0,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trailerNumber': trailerNumber,
      'date': date.toIso8601String(),
      'clientName': clientName,
      'country': country,
      'transporter': transporter,
      'barsCount': barsCount,
      'singlesCount': singlesCount,
      'notes': notes,
    };
  }

  factory AgentExportData.fromJson(Map<String, dynamic> json) {
    return AgentExportData(
      id: json['id'],
      trailerNumber: json['trailerNumber'] ?? json['trailer_number'] ?? '',
      date: DateTime.parse(json['date'] ??
          json['export_date'] ??
          DateTime.now().toIso8601String()),
      clientName: json['clientName'] ?? json['client_name'] ?? '',
      country: json['country'] ?? '',
      transporter: json['transporter'],
      barsCount: json['barsCount'] ?? json['bars_count'] ?? 0,
      singlesCount: json['singlesCount'] ?? json['singles_count'] ?? 0,
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null),
    );
  }
}
