// ===========================================
// DASHBOARD HEADER WIDGET
// ===========================================

import 'package:flutter/material.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/widgets/buttons.dart';

class DashboardHeader extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final Color? backgroundColor;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.onLogout,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              _getRoleIcon(),
              color: _getRoleColor(),
              size: 28,
            ),
          ),
          const SizedBox(width: 15),

          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Notification Icon
          if (onNotificationTap != null)
            IconButtonWithBadge(
              icon: Icons.notifications,
              badgeCount: notificationCount,
              onPressed: onNotificationTap!,
              iconColor: Colors.white,
            ),

          const SizedBox(width: 8),

          // Logout
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Déconnexion',
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (user.role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.agentExport:
        return Icons.upload;
      case UserRole.agentImport:
        return Icons.download;
      case UserRole.partenaire:
        return Icons.handshake;
    }
  }

  Color _getRoleColor() {
    switch (user.role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.agentExport:
        return Colors.green;
      case UserRole.agentImport:
        return const Color(0xFF0C44A6);
      case UserRole.partenaire:
        return Colors.orange;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
