import 'package:flutter/material.dart';
import 'package:import_export_app/models/agent_export_data.dart';
import 'package:import_export_app/services/api_service.dart';

class TrackExportScreen extends StatefulWidget {
  const TrackExportScreen({super.key});

  @override
  State<TrackExportScreen> createState() => _TrackExportScreenState();
}

class _TrackExportScreenState extends State<TrackExportScreen> {
  bool _isLoading = true;
  List<AgentExportData> _exports = [];

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  Future<void> _loadExports() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getExports();
      if (response['success'] == true && response['exports'] != null) {
        final List<dynamic> data = response['exports'] ?? [];
        if (mounted) {
          setState(() {
            _exports = data.map((e) => e as AgentExportData).toList();
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
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
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
                                  Text(
                                    'Remorque: ${export.trailerNumber}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Créé',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildExportRow('Client', export.clientName),
                              _buildExportRow('Pays', export.country),
                              _buildExportRow(
                                  'Date', export.date.toString().split(' ')[0]),
                              _buildExportRow(
                                  'Barres', export.barsCount.toString()),
                              _buildExportRow(
                                  'Singles', export.singlesCount.toString()),
                              if (export.transporter != null)
                                _buildExportRow(
                                    'Transporteur', export.transporter!),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildExportRow(String label, String value) {
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
