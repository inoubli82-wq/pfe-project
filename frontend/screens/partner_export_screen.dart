import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/export_data.dart';

class PartnerExportScreen extends StatefulWidget {
  const PartnerExportScreen({super.key});

  @override
  State<PartnerExportScreen> createState() => _PartnerExportScreenState();
}

class _PartnerExportScreenState extends State<PartnerExportScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final TextEditingController _trailerController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  
  int _numberOfBars = 0;
  int _numberOfStraps = 0;
  int _numberOfSuctionCups = 0;
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _trailerController.dispose();
    _clientController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2026),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}/${date.year}';
  }

  Future<void> _saveExportData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final exportData = ExportData(
        trailerNumber: _trailerController.text.trim().toUpperCase(),
        embarkationDate: _selectedDate,
        clientName: _clientController.text.trim().toUpperCase(),
        numberOfBars: _numberOfBars,
        numberOfStraps: _numberOfStraps,
        numberOfSuctionCups: _numberOfSuctionCups,
      );

      try {
        final success = await _apiService.saveExportData(exportData);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          if (success) {
            _showDialog('Succès', 'Données enregistrées avec succès!');
            _clearForm();
          } else {
            _showDialog('Erreur', 'Erreur lors de l\'enregistrement');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showDialog('Erreur', 'Erreur: ${e.toString()}');
        }
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _trailerController.clear();
    _clientController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _numberOfBars = 0;
      _numberOfStraps = 0;
      _numberOfSuctionCups = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Partenaire Export',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations Partenaire',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Divider(height: 32),
                        
                        // Numéro remorque
                        const Text(
                          'Numéro remorque',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _trailerController,
                          decoration: InputDecoration(
                            hintText: '759-GHZ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.local_shipping),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Champ requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Date d'embarquement
                        const Text(
                          "Date d'embarquement",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.blue),
                                const SizedBox(width: 12),
                                Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nom du client
                        const Text(
                          'Nom du client',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _clientController,
                          decoration: InputDecoration(
                            hintText: 'STÉG',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Champ requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Quantités
                        const Text(
                          'Quantités',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Barres
                        _buildCounter(
                          'Nombre de Barres',
                          _numberOfBars,
                          (v) => setState(() => _numberOfBars = v),
                        ),
                        const SizedBox(height: 16),
                        
                        // Sangles
                        _buildCounter(
                          'Nombre de Sangles',
                          _numberOfStraps,
                          (v) => setState(() => _numberOfStraps = v),
                        ),
                        const SizedBox(height: 16),
                        
                        // Ventouses
                        _buildCounter(
                          'Nombre Ventouses',
                          _numberOfSuctionCups,
                          (v) => setState(() => _numberOfSuctionCups = v),
                        ),
                        const SizedBox(height: 32),
                        
                        // Bouton Enregistrer
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveExportData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Enregistrer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => onChanged(value - 1),
                icon: const Icon(Icons.remove, color: Colors.red),
                constraints: const BoxConstraints(minWidth: 40),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[50],
                ),
              ),
              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add, color: Colors.green),
                constraints: const BoxConstraints(minWidth: 40),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
