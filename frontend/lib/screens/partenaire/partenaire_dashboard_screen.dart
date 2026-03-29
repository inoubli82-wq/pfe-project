// ===========================================
// PARTENAIRE DASHBOARD SCREEN
// ===========================================

import 'package:flutter/material.dart';
import 'package:import_export_app/models/notification_model.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/screens/common/notifications_screen.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';

import 'command_verification_screen.dart';
import 'verification_request_card.dart';

class PartenaireDashboardScreen extends StatefulWidget {
  final User user;

  const PartenaireDashboardScreen({super.key, required this.user});

  @override
  State<PartenaireDashboardScreen> createState() =>
      _PartenaireDashboardScreenState();
}

class _PartenaireDashboardScreenState extends State<PartenaireDashboardScreen> {
  int _unreadCount = 0;
  List<PendingRequest> _pendingExports = [];
  List<PendingRequest> _pendingImports = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadUnreadCount(),
      _loadPendingRequests(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadUnreadCount() async {
    final response = await ApiService.getUnreadCount();
    if (response['success'] == true) {
      setState(() => _unreadCount = response['unreadCount'] ?? 0);
    }
  }

  Future<void> _loadPendingRequests() async {
    final response = await ApiService.getPendingRequests();
    if (response['success'] == true) {
      setState(() {
        _pendingExports = (response['pendingExports'] as List?)
                ?.map((e) => PendingRequest.fromJson(e, 'export'))
                .toList() ??
            [];
        _pendingImports = (response['pendingImports'] as List?)
                ?.map((e) => PendingRequest.fromJson(e, 'import'))
                .toList() ??
            [];
      });
    }
  }

  Future<void> _handleApprove(PendingRequest request) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Approuver la demande',
      message:
          'Êtes-vous sûr de vouloir approuver cette demande ${request.typeDisplayName.toLowerCase()} ?',
      confirmText: 'Approuver',
      confirmColor: Colors.green,
    );

    if (confirmed == true) {
      await _processDecision(request, 'approved');
    }
  }

  Future<void> _handleReject(PendingRequest request) async {
    final reason = await RejectionReasonDialog.show(context);
    if (reason != null && reason.isNotEmpty) {
      await _processDecision(request, 'rejected', reason: reason);
    }
  }

  Future<void> _processDecision(PendingRequest request, String decision,
      {String? reason}) async {
    setState(() => _isProcessing = true);

    final response = await ApiService.handleDecision(
      requestType: request.type,
      requestId: request.id,
      decision: decision,
      reason: reason,
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (response['success'] == true) {
      AppSnackBar.showSuccess(
        context,
        decision == 'approved' ? 'Demande approuvée' : 'Demande refusée',
      );
      _loadData();
    } else {
      AppSnackBar.showError(
        context,
        response['message'] ?? 'Erreur lors du traitement',
      );
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

  void _navigateToSuiviImport() {
    // Navigation vers la page de suivi import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers Suivi Import')),
    );
  }

  void _navigateToCreationExport() {
    // Navigation vers la page de création export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers Création Export')),
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
              // Header simplifié
              _buildSimpleHeader(),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Message de bienvenue
                      _buildWelcomeMessage(),

                      const SizedBox(height: 32),

                      // Carte Suivi Import
                      _buildActionCard(
                        title: 'Suivi Import',
                        subtitle:
                            'Suivre les conteneurs reçus et vérifier les données',
                        icon: Icons.import_export,
                        iconColor: Colors.blue,
                        onTap: _navigateToSuiviImport,
                      ),

                      const SizedBox(height: 20),

                      // Carte Création Export
                      _buildActionCard(
                        title: 'Création Export',
                        subtitle:
                            'Créer un nouveau export et saisir les informations',
                        icon: Icons.add_circle_outline,
                        iconColor: Colors.green,
                        buttonText: 'Créer',
                        onTap: _navigateToCreationExport,
                      ),

                      const SizedBox(height: 32),

                      // Section demandes en attente (optionnelle)
                      if (_pendingExports.isNotEmpty ||
                          _pendingImports.isNotEmpty)
                        _buildPendingRequestsSection(),
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

  Widget _buildSimpleHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo et titre
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'AST',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logitrack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Icône de notification
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationsScreen(user: widget.user),
                    ),
                  ).then((_) => _loadUnreadCount());
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        const Text(
          'Bonjour, Partenaire',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                User.roleToString(widget.user.role),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? buttonText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Bouton d'action
            if (buttonText != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection() {
    final totalPending = _pendingExports.length + _pendingImports.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Demandes en attente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: totalPending > 0
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalPending en attente',
                style: TextStyle(
                  color: totalPending > 0 ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingExports.length + _pendingImports.length,
          itemBuilder: (context, index) {
            final allRequests = [..._pendingExports, ..._pendingImports];
            final request = allRequests[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VerificationRequestCard(
                request: request,
                onRefresh: _loadData,
              ),
            );
          },
        ),
      ],
    );
  }

  void _showRequestDetail(PendingRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommandVerificationScreen(request: request),
      ),
    ).then((_) => _loadData());
  }
}
