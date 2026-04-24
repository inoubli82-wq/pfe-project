import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import 'agent_import_verification_request_card.dart';

class VerifyPartnerExportRequestsScreen extends StatefulWidget {
  const VerifyPartnerExportRequestsScreen({super.key});

  @override
  State<VerifyPartnerExportRequestsScreen> createState() =>
      _VerifyPartnerExportRequestsScreenState();
}

class _VerifyPartnerExportRequestsScreenState
    extends State<VerifyPartnerExportRequestsScreen> {
  bool _isLoading = true;
  List<PendingRequest> _pendingExports = [];

  @override
  void initState() {
    super.initState();
    _loadPendingPartnerExports();
  }

  Future<void> _loadPendingPartnerExports() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getPendingRequests();

    if (response['success'] == true) {
      final exports = (response['pendingExports'] as List?)
              ?.map((e) => PendingRequest.fromJson(e, 'export'))
              .toList() ??
          [];

      exports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _pendingExports = exports;
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vérification des Retours',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: const Color(0xFF0C44A6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPendingPartnerExports,
              child: _pendingExports.isEmpty
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
                            'Aucun retour ou arrivée en attente',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingExports.length,
                      itemBuilder: (context, index) {
                        return AgentImportVerificationRequestCard(
                          request: _pendingExports[index],
                          onRefresh: _loadPendingPartnerExports,
                        );
                      },
                    ),
            ),
    );
  }
}
