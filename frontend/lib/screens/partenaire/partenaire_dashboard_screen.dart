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

class PartenaireDashboardScreen extends StatefulWidget {
  final User user;

  const PartenaireDashboardScreen({Key? key, required this.user})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final totalPending = _pendingExports.length + _pendingImports.length;

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
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: _buildContent(totalPending),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(int totalPending) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Badge
                Center(
                  child: RoleBadge(role: User.roleToString(widget.user.role)),
                ),
                const SizedBox(height: 20),

                // Pending Requests Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Demandes en attente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: totalPending > 0
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalPending en attente',
                        style: TextStyle(
                          color:
                              totalPending > 0 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Pending Requests List
        if (totalPending == 0)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune demande en attente',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final allRequests = [..._pendingExports, ..._pendingImports];
                  final request = allRequests[index];
                  return RequestCard(
                    type: request.type,
                    trailerNumber: request.trailerNumber,
                    entityName: request.entityName,
                    country: request.country,
                    date: request.date,
                    status: request.status,
                    approvalStatus: request.approvalStatus,
                    createdByName: request.createdByName,
                    onTap: () => _showRequestDetail(request),
                    trailing: ApprovalButtons(
                      onApprove: () => _handleApprove(request),
                      onReject: () => _handleReject(request),
                      isLoading: _isProcessing,
                    ),
                  );
                },
                childCount: _pendingExports.length + _pendingImports.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  void _showRequestDetail(PendingRequest request) {
    showDialog(
      context: context,
      builder: (context) => RequestDetailDialog(
        type: request.type,
        trailerNumber: request.trailerNumber,
        entityName: request.entityName,
        country: request.country,
        transporter: request.transporter,
        date: request.date.toString().split(' ')[0],
        status: request.status,
        approvalStatus: request.approvalStatus,
        createdByName: request.createdByName,
        showApprovalButtons: request.isPending,
        onApprove: () {
          Navigator.pop(context);
          _handleApprove(request);
        },
        onReject: () {
          Navigator.pop(context);
          _handleReject(request);
        },
      ),
    );
  }
}
