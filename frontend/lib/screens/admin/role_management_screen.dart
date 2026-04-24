import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  bool _isLoading = true;
  Map<String, int> _roleCounts = {
    'admin': 0,
    'Agent Export': 0,
    'Agent Import': 0,
    'Partenaire': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getAllUsers();
    
    if (mounted) {
      if (response['success'] == true) {
        final users = response['users'] as List? ?? [];
        Map<String, int> counts = {
          'admin': 0,
          'Agent Export': 0,
          'Agent Import': 0,
          'Partenaire': 0,
        };
        
        for (var user in users) {
          String role = user['userType'] ?? '';
          if (counts.containsKey(role)) {
            counts[role] = counts[role]! + 1;
          }
        }
        
        setState(() {
          _roleCounts = counts;
        });
      }
      setState(() => _isLoading = false);
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'admin': return 'Administrateur système avec tous les accès.';
      case 'Agent Export': return 'Gère les exports et les envois de matériel.';
      case 'Agent Import': return 'Gère les imports et la réception de matériel.';
      case 'Partenaire': return 'Partenaire de transport vérifiant les cargaisons.';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Rôles')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _roleCounts.entries.map((entry) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3B70),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${entry.value} Utilisateurs',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getRoleDescription(entry.key),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
