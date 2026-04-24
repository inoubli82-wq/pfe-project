import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'verify_arrival_screen.dart';

class ImportArrivalsScreen extends StatefulWidget {
  const ImportArrivalsScreen({super.key});

  @override
  State<ImportArrivalsScreen> createState() => _ImportArrivalsScreenState();
}

class _ImportArrivalsScreenState extends State<ImportArrivalsScreen> {
  bool _isLoading = true;
  List<dynamic> _arrivals = [];

  @override
  void initState() {
    super.initState();
    _loadArrivals();
  }

  Future<void> _loadArrivals() async {
    setState(() => _isLoading = true);
    // We reuse the getAllExports but filter for 'arrived' status in the UI or a new API if preferred
    // For now, let's get all exports and filter
    final response = await ApiService.getExports();
    if (response['success'] == true) {
      setState(() {
        _arrivals = (response['exports'] as List)
            .where((e) => e['status'] == 'arrived')
            .toList();
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrivées Conteneurs'),
        backgroundColor: const Color(0xFF0C44A6),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadArrivals,
              child: _arrivals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('Aucune arrivée à traiter', style: TextStyle(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _arrivals.length,
                      itemBuilder: (context, index) {
                        final arrival = _arrivals[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Conteneur: ${arrival['container_number'] ?? 'N/A'}', 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(arrival['transporter'] ?? '', 
                                        style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(Icons.calendar_today, 'Arrivée prévue', arrival['expected_arrival_date']?.toString().split('T')[0] ?? ''),
                                const SizedBox(height: 8),
                                _buildInfoRow(Icons.person, 'Client', arrival['client_name'] ?? ''),
                                const SizedBox(height: 8),
                                _buildInfoRow(Icons.numbers, 'Remorque', arrival['trailer_number'] ?? ''),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VerifyArrivalScreen(arrival: arrival),
                                        ),
                                      ).then((_) => _loadArrivals());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0C44A6),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Vérifier et Réceptionner'),
                                  ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
