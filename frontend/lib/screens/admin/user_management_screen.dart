import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getAllUsers();
    if (mounted) {
      if (response['success'] == true) {
        setState(() {
          _users = response['users'] ?? [];
        });
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final response = await ApiService.deleteUser(id);
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur supprimé avec succès')),
        );
      }
      _loadUsers();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Erreur')),
        );
      }
    }
  }

  Future<void> _editRole(int id, String currentRole) async {
    String newRole = currentRole;
    final validRoles = ['admin', 'Agent Export', 'Agent Import', 'Agent de Stock', 'Partenaire'];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Modifier le rôle'),
            content: DropdownButton<String>(
              value: newRole,
              isExpanded: true,
              items: validRoles.map((r) {
                return DropdownMenuItem(value: r, child: Text(r));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setDialogState(() => newRole = val);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enregistrer'),
              ),
            ],
          );
        }
      ),
    );

    if (confirm != true || newRole == currentRole) return;

    setState(() => _isLoading = true);
    final response = await ApiService.updateUserRole(id, newRole);
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôle mis à jour avec succès')),
        );
      }
      _loadUsers();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Erreur')),
        );
      }
    }
  }

  Future<void> _addUser() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'Agent Export';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Ajouter un utilisateur'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom complet')),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true),
                  DropdownButton<String>(
                    value: role,
                    isExpanded: true,
                    items: ['admin', 'Agent Export', 'Agent Import', 'Agent de Stock', 'Partenaire'].map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => role = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajouter')),
            ],
          );
        }
      ),
    );

    if (confirm != true) return;
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    setState(() => _isLoading = true);
    final response = await ApiService.createUser({
      'fullName': nameCtrl.text,
      'email': emailCtrl.text,
      'password': passCtrl.text,
      'userType': role,
    });

    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur créé avec succès')),
        );
      }
      _loadUsers();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Erreur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion Utilisateurs')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.person_add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(user['fullName']?[0] ?? '?')),
                      title: Text(user['fullName'] ?? ''),
                      subtitle: Text('${user['email']}\nRôle: ${user['userType']}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editRole(user['id'], user['userType']),
                            tooltip: 'Modifier le rôle',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user['id']),
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
