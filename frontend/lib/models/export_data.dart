class ExportData {
  final int? id;
  final String trailerNumber;
  final DateTime embarkationDate;
  final String clientName;
  final int numberOfBars;
  final int numberOfStraps;
  final int numberOfSuctionCups;
  final String approvalStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExportData({
    this.id,
    required this.trailerNumber,
    required this.embarkationDate,
    required this.clientName,
    required this.numberOfBars,
    required this.numberOfStraps,
    required this.numberOfSuctionCups,
    this.approvalStatus = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trailerNumber': trailerNumber,
      'embarkationDate': embarkationDate.toIso8601String(),
      'clientName': clientName,
      'numberOfBars': numberOfBars,
      'numberOfStraps': numberOfStraps,
      'numberOfSuctionCups': numberOfSuctionCups,
      'approval_status': approvalStatus,
    };
  }

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      id: json['id'],
      trailerNumber: json['trailer_number'] ?? '',
      embarkationDate: DateTime.parse(
          json['embarkation_date'] ?? DateTime.now().toIso8601String()),
      clientName: json['client_name'] ?? '',
      numberOfBars: json['number_of_bars'] ?? 0,
      numberOfStraps: json['number_of_straps'] ?? 0,
      numberOfSuctionCups: json['number_of_suction_cups'] ?? 0,
      approvalStatus: json['approval_status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
