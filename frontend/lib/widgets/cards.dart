// ===========================================
// REUSABLE CARD WIDGETS
// ===========================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ===========================================
// STATS CARD
// ===========================================
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.grey[400], size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================
// REQUEST CARD
// ===========================================
class RequestCard extends StatelessWidget {
  final String type; // 'export' or 'import'
  final String trailerNumber;
  final String entityName;
  final String country;
  final DateTime date;
  final String status;
  final String approvalStatus;
  final String? createdByName;
  final String? rejectionReason;
  final VoidCallback? onTap;
  final Widget? trailing;

  const RequestCard({
    super.key,
    required this.type,
    required this.trailerNumber,
    required this.entityName,
    required this.country,
    required this.date,
    required this.status,
    required this.approvalStatus,
    this.createdByName,
    this.rejectionReason,
    this.onTap,
    this.trailing,
  });

  Color get _typeColor =>
      type == 'export' ? Colors.green : const Color(0xFF0C44A6);

  Color get _statusColor {
    switch (approvalStatus) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get _statusText {
    switch (approvalStatus) {
      case 'approved':
        return 'Approuvé';
      case 'rejected':
        return 'Refusé';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _typeColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              color: _typeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trailerNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _statusColor),
                        ),
                        child: Text(
                          _statusText,
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              // Details
              _buildDetailRow(
                Icons.business,
                type == 'export' ? 'Client' : 'Fournisseur',
                entityName,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_on, 'Pays', country),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                DateFormat('dd/MM/yyyy').format(date),
              ),
              if (createdByName != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(Icons.person, 'Créé par', createdByName!),
              ],
              if (approvalStatus == 'rejected' && rejectionReason != null && rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Motif du refus: $rejectionReason',
                          style: TextStyle(color: Colors.red[900], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Trailing widget (e.g., approval buttons)
              if (trailing != null) ...[
                const SizedBox(height: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ===========================================
// NOTIFICATION CARD
// ===========================================
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final bool actionRequired;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.actionRequired = false,
    this.onTap,
    this.onDismiss,
  });

  IconData get _icon {
    switch (type) {
      case 'export_request':
        return Icons.upload;
      case 'import_request':
        return Icons.download;
      case 'approval':
        return Icons.check_circle;
      case 'rejection':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color get _color {
    switch (type) {
      case 'export_request':
        return Colors.green;
      case 'import_request':
        return const Color(0xFF0C44A6);
      case 'approval':
        return Colors.green;
      case 'rejection':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(createdAt.toString()),
      direction: onDismiss != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: isRead ? Colors.white : const Color(0xFF0C44A6),
        elevation: isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: actionRequired
              ? const BorderSide(color: Colors.orange, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: _color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(createdAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (actionRequired) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Action requise',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0C44A6),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return "À l'instant";
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return DateFormat('dd/MM').format(dt);
    }
  }
}

// ===========================================
// ROLE BADGE
// ===========================================
class RoleBadge extends StatelessWidget {
  final String role;
  final Color? color;

  const RoleBadge({
    super.key,
    required this.role,
    this.color,
  });

  Color get _color {
    if (color != null) return color!;
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'agent export':
        return Colors.green;
      case 'agent import':
        return const Color(0xFF0C44A6);
      case 'partenaire':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get _icon {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'agent export':
        return Icons.upload;
      case 'agent import':
        return Icons.download;
      case 'partenaire':
        return Icons.handshake;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: 18),
          const SizedBox(width: 8),
          Text(
            role,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
