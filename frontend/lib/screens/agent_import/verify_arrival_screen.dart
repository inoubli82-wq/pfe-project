import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VerifyArrivalScreen extends StatefulWidget {
  final Map<String, dynamic> arrival;

  const VerifyArrivalScreen({super.key, required this.arrival});

  @override
  State<VerifyArrivalScreen> createState() => _VerifyArrivalScreenState();
}

class _VerifyArrivalScreenState extends State<VerifyArrivalScreen> {
  final _barsController = TextEditingController();
  final _singlesController = TextEditingController();
  final _suctionCupsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final expectedBars = widget.arrival['bars_count'] ?? 0;
    final expectedSingles = widget.arrival['singles_count'] ?? 0;
    final expectedSuctionCups = widget.arrival['suction_cups_count'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification Réception'),
        backgroundColor: const Color(0xFF0C44A6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(expectedBars, expectedSingles, expectedSuctionCups),
            const SizedBox(height: 30),
            const Text('Veuillez saisir les quantités trouvées :', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C44A6))),
            const SizedBox(height: 20),
            _buildCountField('Nombre de Barres', _barsController, Icons.view_headline),
            const SizedBox(height: 15),
            _buildCountField('Nombre de Singles', _singlesController, Icons.exposure_plus_1),
            const SizedBox(height: 15),
            _buildCountField('Nombre de Vantouses', _suctionCupsController, Icons.radio_button_checked),
            const SizedBox(height: 25),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes / Observations',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReception,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C44A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmer la Réception', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int bars, int singles, int suctionCups) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quantités Attendues', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildExpectedItem('Barres', bars),
              _buildExpectedItem('Singles', singles),
              _buildExpectedItem('Vantouses', suctionCups),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpectedItem(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0C44A6))),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildCountField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0C44A6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> _submitReception() async {
    final bars = int.tryParse(_barsController.text);
    final singles = int.tryParse(_singlesController.text);
    final suctionCups = int.tryParse(_suctionCupsController.text);

    if (bars == null || singles == null || suctionCups == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir des nombres valides pour toutes les quantités')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.receiveExport(
        id: widget.arrival['id'],
        receivedBars: bars,
        receivedSingles: singles,
        receivedSuctionCups: suctionCups,
        notes: _notesController.text,
      );

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réception confirmée ! Le stock a été mis à jour.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Erreur lors de la réception')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
