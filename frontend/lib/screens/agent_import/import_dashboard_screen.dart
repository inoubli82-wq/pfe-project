import 'package:flutter/material.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/screens/common/notifications_screen.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';

// ===========================================
// IMPORT AGENT DASHBOARD
// ===========================================

class ImportDashboardScreen extends StatefulWidget {
  final User user;

  const ImportDashboardScreen({super.key, required this.user});

  @override
  State<ImportDashboardScreen> createState() => _ImportDashboardScreenState();
}

class _ImportDashboardScreenState extends State<ImportDashboardScreen> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final response = await ApiService.getUnreadCount();
    if (response['success'] == true) {
      setState(() => _unreadCount = response['unreadCount'] ?? 0);
    }
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/login_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0x99000000),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              DashboardHeader(
                user: widget.user,
                onLogout: _logout,
                notificationCount: _unreadCount,
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationsScreen(user: widget.user),
                    ),
                  ).then((_) => _loadUnreadCount());
                },
              ),

              // Main Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Role Badge
                      RoleBadge(role: User.roleToString(widget.user.role)),

                      const SizedBox(height: 30),

                      // Create Import Button
                      ActionCardButton(
                        title: 'Créer un dossier import',
                        subtitle: 'Démarrer une nouvelle importation',
                        icon: Icons.add_box,
                        color: Colors.blue.shade700,
                        onTap: () =>
                            _showFeatureDialog(context, 'Créer Import'),
                      ),

                      const SizedBox(height: 20),

                      // Track Import Button
                      ActionCardButton(
                        title: 'Suivre l\'import',
                        subtitle: 'Suivre le statut de vos importations',
                        icon: Icons.track_changes,
                        color: Colors.teal,
                        onTap: () =>
                            _showFeatureDialog(context, 'Suivi Import'),
                      ),

                      const SizedBox(height: 20),

                      // Notifications Button
                      ActionCardButton(
                        title: 'Notifications',
                        subtitle: 'Voir les mises à jour de vos demandes',
                        icon: Icons.notifications,
                        color: Colors.orange,
                        badgeCount: _unreadCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NotificationsScreen(user: widget.user),
                            ),
                          ).then((_) => _loadUnreadCount());
                        },
                      ),

                      const Spacer(),

                      // Info Text
                      Text(
                        'Les demandes d\'import nécessitent l\'approbation du partenaire',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
