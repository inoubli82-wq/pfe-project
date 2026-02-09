// ===========================================
// NOTIFICATION MODEL
// ===========================================

enum NotificationType {
  exportRequest,
  importRequest,
  approval,
  rejection,
  info,
}

class NotificationModel {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final String? referenceType;
  final int? referenceId;
  final int? senderId;
  final String? senderName;
  final int recipientId;
  final bool isRead;
  final bool actionRequired;
  final String? actionTaken;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    this.senderId,
    this.senderName,
    required this.recipientId,
    required this.isRead,
    required this.actionRequired,
    this.actionTaken,
    required this.createdAt,
    this.readAt,
  });

  static NotificationType stringToType(String typeStr) {
    switch (typeStr) {
      case 'export_request':
        return NotificationType.exportRequest;
      case 'import_request':
        return NotificationType.importRequest;
      case 'approval':
        return NotificationType.approval;
      case 'rejection':
        return NotificationType.rejection;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: stringToType(json['type'] ?? 'info'),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      recipientId: json['recipient_id'] ?? 0,
      isRead: json['is_read'] ?? false,
      actionRequired: json['action_required'] ?? false,
      actionTaken: json['action_taken'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'sender_id': senderId,
      'sender_name': senderName,
      'recipient_id': recipientId,
      'is_read': isRead,
      'action_required': actionRequired,
      'action_taken': actionTaken,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isExportRequest => type == NotificationType.exportRequest;
  bool get isImportRequest => type == NotificationType.importRequest;
  bool get isApproval => type == NotificationType.approval;
  bool get isRejection => type == NotificationType.rejection;
  bool get needsAction => actionRequired && actionTaken == null;

  String get typeDisplayName {
    switch (type) {
      case NotificationType.exportRequest:
        return 'Demande Export';
      case NotificationType.importRequest:
        return 'Demande Import';
      case NotificationType.approval:
        return 'Approuvé';
      case NotificationType.rejection:
        return 'Refusé';
      case NotificationType.info:
        return 'Information';
    }
  }

  @override
  String toString() {
    return 'NotificationModel{id: $id, title: $title, isRead: $isRead}';
  }
}

// ===========================================
// PENDING REQUEST MODEL
// ===========================================

class PendingRequest {
  final int id;
  final String type; // 'export' or 'import'
  final String trailerNumber;
  final DateTime date;
  final String entityName; // client_name for export, supplier_name for import
  final String country;
  final String? transporter;
  final String status;
  final String approvalStatus;
  final int? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final int? barsCount;
  final int? singlesCount;

  PendingRequest({
    required this.id,
    required this.type,
    required this.trailerNumber,
    required this.date,
    required this.entityName,
    required this.country,
    this.transporter,
    required this.status,
    required this.approvalStatus,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.barsCount,
    this.singlesCount,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json, String type) {
    return PendingRequest(
      id: json['id'] ?? 0,
      type: type,
      trailerNumber: json['trailer_number'] ?? '',
      date: json['export_date'] != null
          ? DateTime.parse(json['export_date'])
          : (json['import_date'] != null
              ? DateTime.parse(json['import_date'])
              : DateTime.now()),
      entityName: json['client_name'] ?? json['supplier_name'] ?? '',
      country: json['country'] ?? '',
      transporter: json['transporter'],
      status: json['status'] ?? 'pending',
      approvalStatus: json['approval_status'] ?? 'pending',
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      barsCount: json['bars_count'],
      singlesCount: json['singles_count'],
    );
  }

  bool get isPending => approvalStatus == 'pending';
  bool get isApproved => approvalStatus == 'approved';
  bool get isRejected => approvalStatus == 'rejected';

  String get typeDisplayName => type == 'export' ? 'Export' : 'Import';

  @override
  String toString() {
    return 'PendingRequest{id: $id, type: $type, trailerNumber: $trailerNumber}';
  }
}
