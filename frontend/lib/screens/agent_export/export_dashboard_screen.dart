import 'package:flutter/material.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/agent_export/create_export_screen.dart';
import 'package:import_export_app/screens/agent_export/track_export_screen.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/screens/common/notifications_screen.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';

// ===========================================
// EXPORT AGENT DASHBOARD
// ===========================================

class ExportDashboardScreen extends StatefulWidget {
  final User user;

  const ExportDashboardScreen({super.key, required this.user});

  @override
  State<ExportDashboardScreen> createState() => _ExportDashboardScreenState();
}

class _ExportDashboardScreenState extends State<ExportDashboardScreen> {
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

              // Main Content - Centered buttons only
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Create Export Button
                        ActionCardButton(
                          title: 'Créer un dossier export',
                          subtitle: '',
                          icon: Icons.create_new_folder,
                          color: const Color(0xFF0C44A6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateExportPage(),
                            ),
                          ).then((_) => _loadUnreadCount()),
                        ),

                        const SizedBox(height: 20),

                        // Track Export Button
                        ActionCardButton(
                          title: 'Suivre l\'export',
                          subtitle: '',
                          icon: Icons.track_changes,
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrackExportScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
