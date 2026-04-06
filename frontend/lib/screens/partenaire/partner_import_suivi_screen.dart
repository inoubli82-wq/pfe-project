import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'verification_request_card.dart';

class PartnerImportSuiviScreen extends StatefulWidget {
  final User user;

  const PartnerImportSuiviScreen({super.key, required this.user});

  @override
  State<PartnerImportSuiviScreen> createState() =>
      _PartnerImportSuiviScreenState();
}

class _PartnerImportSuiviScreenState extends State<PartnerImportSuiviScreen> {
  bool _isLoading = true;
  List<PendingRequest> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getPendingRequests();

    if (response['success'] == true) {
      final imports = (response['pendingImports'] as List?)
              ?.map((e) => PendingRequest.fromJson(e, 'import'))
              .toList() ??
          [];

      final exports = (response['pendingExports'] as List?)
              ?.map((e) => PendingRequest.fromJson(e, 'export'))
              .toList() ??
          [];

      setState(() {
        _pendingRequests = [...imports, ...exports];
        // Tri par date la plus récente
        _pendingRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vérification des Demandes',
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
              onRefresh: _loadRequests,
              child: _pendingRequests.isEmpty
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
                            'Aucune demande en attente',
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
                      itemCount: _pendingRequests.length,
                      itemBuilder: (context, index) {
                        return VerificationRequestCard(
                          request: _pendingRequests[index],
                          onRefresh: _loadRequests,
                        );
                      },
                    ),
            ),
    );
  }
}
