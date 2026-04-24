import 'package:flutter/material.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/screens/common/notifications_screen.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';

import 'verify_partner_export_requests_screen.dart';
import 'import_history_screen.dart';

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
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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

                      ActionCardButton(
                        title: 'Vérifier retours et arrivées',
                        subtitle:
                            'Contrôler les barres ramenées par le transporteur au retour',
                        icon: Icons.fact_check,
                        color: const Color(0xFF0C44A6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VerifyPartnerExportRequestsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Historique
                      ActionCardButton(
                        title: 'Historique des vérifications',
                        subtitle: 'Consulter l\'historique des demandes traitées',
                        icon: Icons.history,
                        color: Colors.blueGrey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImportHistoryScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      const Spacer(),

                      // Info Text
                      Text(
                        'Vous traitez toutes les demandes de retour et les arrivées de conteneurs',
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
}
