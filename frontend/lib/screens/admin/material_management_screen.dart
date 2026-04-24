import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MaterialManagementScreen extends StatefulWidget {
  const MaterialManagementScreen({super.key});

  @override
  State<MaterialManagementScreen> createState() => _MaterialManagementScreenState();
}

class _MaterialManagementScreenState extends State<MaterialManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getDashboardStats();
    if (mounted) {
      if (response['success'] == true) {
        setState(() {
          _stats = response['stats'] ?? {};
        });
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi du Matériel')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Le suivi du matériel est calculé automatiquement à partir des flux d\'export et d\'import.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  _buildStatRow('Total Exports Traités', _stats['totalExports']?.toString() ?? '0', Icons.arrow_upward),
                  _buildStatRow('Total Imports Traités', _stats['totalImports']?.toString() ?? '0', Icons.arrow_downward),
                  _buildStatRow('Demandes en attente', _stats['pendingRequests']?['total']?.toString() ?? '0', Icons.pending_actions),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E3B70)),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
