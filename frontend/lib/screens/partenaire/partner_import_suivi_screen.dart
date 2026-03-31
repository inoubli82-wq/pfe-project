import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/widgets.dart';

class PartnerImportSuiviScreen extends StatefulWidget {
  final User user;

  const PartnerImportSuiviScreen({super.key, required this.user});

  @override
  State<PartnerImportSuiviScreen> createState() =>
      _PartnerImportSuiviScreenState();
}

class _PartnerImportSuiviScreenState extends State<PartnerImportSuiviScreen> {
  bool _isLoading = true;
  List<PendingRequest> _pendingImports = [];

  @override
  void initState() {
    super.initState();
    _loadImports();
  }

  Future<void> _loadImports() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getPendingRequests();

    if (response['success'] == true) {
      setState(() {
        _pendingImports = (response['pendingImports'] as List?)
                ?.map((e) => PendingRequest.fromJson(e, 'import'))
                .toList() ??
            [];
      });
    }

    setState(() => _isLoading = false);
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
    final response = await ApiService.handleDecision(
      requestType: request.type,
      requestId: request.id,
      decision: decision,
      reason: reason,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      AppSnackBar.showSuccess(
        context,
        decision == 'approved' ? 'Demande approuvée' : 'Demande refusée',
      );
      _loadImports();
    } else {
      AppSnackBar.showError(
        context,
        response['message'] ?? 'Erreur lors du traitement',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suivi Import',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadImports,
              child: _pendingImports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun import en attente',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingImports.length,
                      itemBuilder: (context, index) {
                        final request = _pendingImports[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Demande #${request.id}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'En attente',
                                        style: TextStyle(
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow('Type', request.typeDisplayName),
                                _buildInfoRow(
                                    'Date',
                                    '${request.createdAt.day}/'
                                        '${request.createdAt.month}/'
                                        '${request.createdAt.year}'),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handleReject(request),
                                        icon: const Icon(Icons.close),
                                        label: const Text('Refuser'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[400],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _handleApprove(request),
                                        icon: const Icon(Icons.check),
                                        label: const Text('Approuver'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[400],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
