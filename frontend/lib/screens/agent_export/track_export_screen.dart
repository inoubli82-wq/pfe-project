import 'package:flutter/material.dart';
import 'package:import_export_app/models/agent_export_data.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/screens/agent_export/edit_export_screen.dart';

class TrackExportScreen extends StatefulWidget {
  const TrackExportScreen({super.key});

  @override
  State<TrackExportScreen> createState() => _TrackExportScreenState();
}

class _TrackExportScreenState extends State<TrackExportScreen> {
  bool _isLoading = true;
  List<AgentExportData> _exports = [];
  String _searchQuery = '';

  List<AgentExportData> get _filteredExports {
    if (_searchQuery.isEmpty) return _exports;
    final query = _searchQuery.toLowerCase();
    return _exports.where((export) {
      final clientMatch = export.clientName.toLowerCase().contains(query);
      final dateMatch = export.date.toString().toLowerCase().contains(query);
      
      // Map status to display text for searching
      String statusDisplay = 'En cours';
      if (export.approvalStatus == 'approved') {
        statusDisplay = 'Confirmé';
      } else if (export.approvalStatus == 'rejected') {
        statusDisplay = 'Refusé';
      } else if (export.approvalStatus == 'cancelled') {
        statusDisplay = 'Annulé';
      }
      
      final statusMatch = statusDisplay.toLowerCase().contains(query);
      
      return clientMatch || dateMatch || statusMatch;
    }).toList();
  }

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
      body: Column(
        children: [
          if (!_isLoading && _exports.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Client, date (AAAA-MM-JJ) ou statut...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _exports.isEmpty
                    ? _buildEmptyState()
                    : _filteredExports.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun résultat pour cette recherche',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadExports,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredExports.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final export = _filteredExports[index];
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
                                  Builder(
                                    builder: (context) {
                                      String statusText = 'En cours';
                                      Color textColor = Colors.orange[700]!;
                                      Color bgColor = Colors.orange[50]!;

                                      if (export.approvalStatus == 'approved') {
                                        statusText = 'Confirmé';
                                        textColor = Colors.green[700]!;
                                        bgColor = Colors.green[50]!;
                                      } else if (export.approvalStatus == 'rejected') {
                                        statusText = 'Refusé';
                                        textColor = Colors.red[700]!;
                                        bgColor = Colors.red[50]!;
                                      } else if (export.approvalStatus == 'cancelled') {
                                        statusText = 'Annulé';
                                        textColor = Colors.grey[700]!;
                                        bgColor = Colors.grey[200]!;
                                      }

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    },
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
                              _buildExportRow('Vantouses',
                                  export.suctionCupsCount.toString()),
                              if (export.transporter != null)
                                _buildExportRow(
                                    'Transporteur', export.transporter!),

                              // Action Buttons
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Edit & Cancel (only for pending)
                                  if (export.approvalStatus == 'pending') ...[
                                    TextButton.icon(
                                      onPressed: () => _editExport(export),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Modifier'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue[700],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _confirmCancel(export),
                                      icon: const Icon(Icons.cancel_outlined, size: 18),
                                      label: const Text('Annuler'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.orange[700],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  // Delete Button (Always available)
                                  IconButton(
                                    onPressed: () => _confirmDelete(export),
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red[700],
                                    tooltip: 'Supprimer',
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
          ),
        ],
      ),
    );
  }

  void _editExport(AgentExportData export) {
    // Navigate to EditExportPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExportPage(export: export),
      ),
    ).then((updated) {
      if (updated == true) _loadExports();
    });
  }

  void _confirmCancel(AgentExportData export) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler l\'export'),
        content: const Text('Êtes-vous sûr de vouloir annuler cet export ? Le stock sera restauré.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _handleCancel(export);
            },
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel(AgentExportData export) async {
    if (export.id == null) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.updateExportStatus(export.id!, 'cancelled');
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export annulé avec succès'), backgroundColor: Colors.green),
          );
          _loadExports();
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Erreur lors de l\'annulation')),
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

  void _confirmDelete(AgentExportData export) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'export'),
        content: const Text('Cette action est irréversible. Le stock sera restauré. Voulez-vous continuer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _handleDelete(export);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(AgentExportData export) async {
    if (export.id == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.deleteExport(export.id!);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export supprimé avec succès'), backgroundColor: Colors.green),
          );
          _loadExports();
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Erreur lors de la suppression')),
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
