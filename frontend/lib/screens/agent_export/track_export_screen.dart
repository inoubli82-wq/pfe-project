import 'package:flutter/material.dart';
import 'package:import_export_app/models/notification_model.dart'; // Reusing PendingRequest model which fits well
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';

class TrackExportScreen extends StatefulWidget {
  const TrackExportScreen({super.key});

  @override
  State<TrackExportScreen> createState() => _TrackExportScreenState();
}

class _TrackExportScreenState extends State<TrackExportScreen> {
  bool _isLoading = true;
  List<PendingRequest> _exports = [];

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  Future<void> _loadExports() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getExports();
      if (response['success'] == true) {
        final List<dynamic> data = response['exports'] ?? [];
        if (mounted) {
          setState(() {
            _exports =
                data.map((e) => PendingRequest.fromJson(e, 'export')).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Erreur de chargement')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text(
          'Suivi Export',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0C44A6), // App primary color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exports.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadExports,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exports.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final export = _exports[index];
                      return RequestCard(
                        type: 'export',
                        trailerNumber: export.trailerNumber,
                        entityName: export.entityName,
                        country: export.country,
                        date: export.date,
                        status: export.status,
                        approvalStatus: export.approvalStatus,
                        createdByName: export.createdByName,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun dossier export trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadExports,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}
