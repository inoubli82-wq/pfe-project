import 'package:flutter/material.dart';

import '../../models/export_data.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/widgets.dart';

class PartnerSuiviScreen extends StatefulWidget {
  final User user;

  const PartnerSuiviScreen({super.key, required this.user});

  @override
  State<PartnerSuiviScreen> createState() => _PartnerSuiviScreenState();
}

class _PartnerSuiviScreenState extends State<PartnerSuiviScreen> {
  bool _isLoading = true;
  List<ExportData> _exports = [];

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  Future<void> _loadExports() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getAllExportData();

    if (response['success'] == true && response['data'] != null) {
      setState(() {
        _exports = (response['data'] as List).cast<ExportData>();
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suivi des Exports',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
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
              onRefresh: _loadExports,
              child: _exports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun export trouvé',
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
                      itemCount: _exports.length,
                      itemBuilder: (context, index) {
                        final export = _exports[index];
                        return RequestCard(
                          type: 'export',
                          trailerNumber: export.trailerNumber,
                          entityName: export.clientName,
                          country:
                              '', // 'Country' not directly available in ExportData here, leave empty if not present
                          date: export.embarkationDate,
                          status: export.approvalStatus,
                          approvalStatus: export.approvalStatus,
                          createdByName: widget.user.fullName,
                        );
                      },
                    ),
            ),
    );
  }
}
