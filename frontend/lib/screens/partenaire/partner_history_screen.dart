import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import '../../widgets/cards.dart';

class PartnerHistoryScreen extends StatefulWidget {
  const PartnerHistoryScreen({super.key});

  @override
  State<PartnerHistoryScreen> createState() => _PartnerHistoryScreenState();
}

class _PartnerHistoryScreenState extends State<PartnerHistoryScreen> {
  bool _isLoading = true;
  List<PendingRequest> _historyExports = [];
  List<PendingRequest> _historyImports = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryRequests();
  }

  Future<void> _loadHistoryRequests() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getHistoryRequests();

    if (response['success'] == true) {
      final exports = (response['historyExports'] as List?)
              ?.map((e) => PendingRequest.fromJson(e, 'export'))
              .toList() ??
          [];
      final imports = (response['historyImports'] as List?)
              ?.map((i) => PendingRequest.fromJson(i, 'import'))
              .toList() ??
          [];

      exports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      imports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _historyExports = exports;
        _historyImports = imports;
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            labelColor: Color(0xFF0C44A6),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0C44A6),
            tabs: [
              Tab(text: 'Historique Mes Retours'),
              Tab(text: 'Historique Commandes Reçues'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildHistoryList(_historyExports),
                  _buildHistoryList(_historyImports),
                ],
              ),
      ),
    );
  }

  Widget _buildHistoryList(List<PendingRequest> requests) {
    return RefreshIndicator(
      onRefresh: _loadHistoryRequests,
      child: requests.isEmpty
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
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
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
    );
  }
}
