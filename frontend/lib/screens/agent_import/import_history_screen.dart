import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import '../../widgets/cards.dart';

class ImportHistoryScreen extends StatefulWidget {
  const ImportHistoryScreen({super.key});

  @override
  State<ImportHistoryScreen> createState() => _ImportHistoryScreenState();
}

class _ImportHistoryScreenState extends State<ImportHistoryScreen> {
  bool _isLoading = true;
  List<PendingRequest> _historyExports = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryExports();
  }

  Future<void> _loadHistoryExports() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getHistoryRequests();

    if (response['success'] == true) {
      final exports = (response['historyExports'] as List?)
              ?.map((e) => PendingRequest.fromJson(e, 'export'))
              .toList() ??
          [];

      exports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _historyExports = exports;
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
          'Historique des vérifications',
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
              onRefresh: _loadHistoryExports,
              child: _historyExports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun historique disponible',
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
                      itemCount: _historyExports.length,
                      itemBuilder: (context, index) {
                        final req = _historyExports[index];
                        return RequestCard(
                          type: req.type,
                          trailerNumber: req.trailerNumber,
                          entityName: req.entityName,
                          country: req.country,
                          date: req.createdAt,
                          status: req.status,
                          approvalStatus: req.approvalStatus,
                          rejectionReason: req.rejectionReason,
                          createdByName: req.createdByName,
                        );
                      },
                    ),
            ),
    );
  }
}
