import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';

/// ============================================
/// STATUS BADGE - Reusable Status Indicator
/// ============================================

enum StatusType {
  pending,
  inProgress,
  completed,
  cancelled,
  approved,
  rejected,
  custom
}

class AppStatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;
  final IconData? icon;
  final Color? customColor;
  final Color? customBackgroundColor;
  final double fontSize;
  final EdgeInsets padding;

  const AppStatusBadge({
    super.key,
    required this.text,
    this.type = StatusType.custom,
    this.icon,
    this.customColor,
    this.customBackgroundColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  // Factory constructors for common statuses
  factory AppStatusBadge.pending({String? text}) {
    return AppStatusBadge(
      text: text ?? 'En attente',
      type: StatusType.pending,
      icon: Icons.access_time,
    );
  }

  factory AppStatusBadge.inProgress({String? text}) {
    return AppStatusBadge(
      text: text ?? 'En cours',
      type: StatusType.inProgress,
      icon: Icons.sync,
    );
  }

  factory AppStatusBadge.completed({String? text}) {
    return AppStatusBadge(
      text: text ?? 'Terminé',
      type: StatusType.completed,
      icon: Icons.check_circle,
    );
  }

  factory AppStatusBadge.cancelled({String? text}) {
    return AppStatusBadge(
      text: text ?? 'Annulé',
      type: StatusType.cancelled,
      icon: Icons.cancel,
    );
  }

  factory AppStatusBadge.approved({String? text}) {
    return AppStatusBadge(
      text: text ?? 'Approuvé',
      type: StatusType.approved,
      icon: Icons.verified,
    );
  }

  factory AppStatusBadge.rejected({String? text}) {
    return AppStatusBadge(
      text: text ?? 'Rejeté',
      type: StatusType.rejected,
      icon: Icons.block,
    );
  }

  /// Create badge from status string
  factory AppStatusBadge.fromStatus(String status) {
    final formattedStatus = Formatters.status(status);

    switch (status.toLowerCase()) {
      case 'pending':
      case 'en attente':
        return AppStatusBadge.pending(text: formattedStatus);
      case 'in_progress':
      case 'inprogress':
      case 'en cours':
        return AppStatusBadge.inProgress(text: formattedStatus);
      case 'completed':
      case 'terminé':
        return AppStatusBadge.completed(text: formattedStatus);
      case 'cancelled':
      case 'annulé':
        return AppStatusBadge.cancelled(text: formattedStatus);
      case 'approved':
      case 'approuvé':
        return AppStatusBadge.approved(text: formattedStatus);
      case 'rejected':
      case 'rejeté':
        return AppStatusBadge.rejected(text: formattedStatus);
      default:
        return AppStatusBadge(text: formattedStatus);
    }
  }

  Color get _color {
    if (customColor != null) return customColor!;

    switch (type) {
      case StatusType.pending:
        return AppColors.warning;
      case StatusType.inProgress:
        return AppColors.info;
      case StatusType.completed:
        return AppColors.success;
      case StatusType.cancelled:
        return AppColors.textSecondary;
      case StatusType.approved:
        return AppColors.success;
      case StatusType.rejected:
        return AppColors.error;
      case StatusType.custom:
        return AppColors.primary;
    }
  }

  Color get _backgroundColor {
    if (customBackgroundColor != null) return customBackgroundColor!;
    return _color.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: _color,
              size: fontSize + 2,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: _color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ROLE BADGE ====================
class AppRoleBadge extends StatelessWidget {
  final String role;
  final bool showIcon;
  final double fontSize;

  const AppRoleBadge({
    super.key,
    required this.role,
    this.showIcon = true,
    this.fontSize = 12,
  });

  Color get _color {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.adminColor;
      case 'agent export':
      case 'agentexport':
        return AppColors.exportColor;
      case 'agent import':
      case 'agentimport':
        return AppColors.importColor;
      case 'partenaire':
        return AppColors.partenaireColor;
      default:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'agent export':
      case 'agentexport':
        return Icons.upload;
      case 'agent import':
      case 'agentimport':
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_icon, color: _color, size: fontSize + 2),
            const SizedBox(width: 4),
          ],
          Text(
            role,
            style: TextStyle(
              color: _color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== COUNT BADGE ====================
class AppCountBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final double size;
  final bool showZero;

  const AppCountBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 18,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showZero) {
      return const SizedBox.shrink();
    }

    final displayText = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        shape: displayText.length == 1 ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            displayText.length > 1 ? BorderRadius.circular(size / 2) : null,
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
