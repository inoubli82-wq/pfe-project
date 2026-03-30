import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/widgets.dart';
import '../../models/export_data.dart';

class PartnerExportScreen extends StatefulWidget {
  const PartnerExportScreen({super.key});

  @override
  State<PartnerExportScreen> createState() => _PartnerExportScreenState();
}

class _PartnerExportScreenState extends State<PartnerExportScreen> {
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2027, 12, 31),
        helpText: 'Choisir une date',
        cancelText: 'Annuler',
        confirmText: 'OK',
      );

      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
        debugPrint('📅 Date sélectionnée: $_selectedDate');
      }
    } catch (e) {
      debugPrint('❌ Erreur calendrier: $e');
    }
  }

  Future<void> _saveExportData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final exportData = ExportData(
          trailerNumber: _trailerController.text.trim().toUpperCase(),
          embarkationDate: _selectedDate,
          clientName: _clientController.text.trim().toUpperCase(),
          numberOfBars: _numberOfBars,
          numberOfStraps: _numberOfStraps,
          numberOfSuctionCups: _numberOfSuctionCups,
        );

        final response = await ApiService.createExportData(exportData);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response['success'] == true) {
            AppSnackBar.showSuccess(
              context,
              'Données enregistrées avec succès!',
            );
            _clearForm();
          } else {
            final message =
                response['message'] ?? 'Erreur lors de l\'enregistrement';
            AppSnackBar.showError(context, message);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          AppSnackBar.showError(context, 'Erreur: ${e.toString()}');
        }
      }
    }
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

  Widget _buildCounterRow(String label, int value, Function(int) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (value > 0) {
                      onChanged(value - 1);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: Colors.red[700], size: 20),
                  ),
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    onChanged(value + 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.blue[700], size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Partenaire Export',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearForm,
            tooltip: 'Réinitialiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Enregistrement en cours...',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.business,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Nouvel Export Partenaire',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Numéro remorque
                            const Text(
                              'Numéro remorque',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _trailerController,
                              decoration: InputDecoration(
                                hintText: 'Ex: 759-GHZ',
                                prefixIcon: const Icon(Icons.local_shipping,
                                    color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Numéro remorque requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Date d'embarquement
                            // Calendrier pour date d'embarquement
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 18.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF0C44A6),
                                    ),
                                    const SizedBox(width: 15.0),
                                    Expanded(
                                      child: Text(
                                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF0C44A6),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20.0),

                            // Nom du client
                            const Text(
                              'Nom du client',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _clientController,
                              decoration: InputDecoration(
                                hintText: 'Ex: STÉG',
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nom client requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Section Compteurs
                            const Text(
                              'Quantités',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Nombre de Barres
                            _buildCounterRow(
                              'Nombre de Barres',
                              _numberOfBars,
                              (value) => setState(() => _numberOfBars = value),
                            ),

                            // Nombre de Sangles
                            _buildCounterRow(
                              'Nombre de Sangles',
                              _numberOfStraps,
                              (value) =>
                                  setState(() => _numberOfStraps = value),
                            ),

                            // Nombre Ventouses
                            _buildCounterRow(
                              'Nombre Ventouses',
                              _numberOfSuctionCups,
                              (value) =>
                                  setState(() => _numberOfSuctionCups = value),
                            ),

                            const SizedBox(height: 24),

                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _saveExportData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Enregistrer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
