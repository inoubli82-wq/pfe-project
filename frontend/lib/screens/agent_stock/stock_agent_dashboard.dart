import 'package:flutter/material.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/dashboard_header.dart';
import 'package:import_export_app/screens/common/login_screen.dart';

class StockAgentDashboard extends StatefulWidget {
  final User user;

  const StockAgentDashboard({super.key, required this.user});

  @override
  State<StockAgentDashboard> createState() => _StockAgentDashboardState();
}

class _StockAgentDashboardState extends State<StockAgentDashboard> {
  bool _isLoading = true;
  List<dynamic> _stocks = [];

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  Future<void> _fetchStocks() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getStocks();
      if (response['success'] == true) {
        setState(() {
          _stocks = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Erreur lors de la récupération des stocks')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion au serveur')),
        );
      }
    }
  }

  void _showUpdateDialog(Map<String, dynamic> stock) {
    final barsController = TextEditingController(text: stock['bars_count'].toString());
    final singlesController = TextEditingController(text: stock['singles_count'].toString());
    final suctionCupsController = TextEditingController(text: stock['suction_cups_count'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mettre à jour Stock - ${stock['transporter']}', 
          style: const TextStyle(color: Color(0xFF0C44A6), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStockField('Barres', barsController, Icons.view_headline),
              const SizedBox(height: 15),
              _buildStockField('Singles', singlesController, Icons.exposure_plus_1),
              const SizedBox(height: 15),
              _buildStockField('Vantouses', suctionCupsController, Icons.radio_button_checked),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await ApiService.updateStock(
                transporter: stock['transporter'],
                barsCount: int.tryParse(barsController.text) ?? 0,
                singlesCount: int.tryParse(singlesController.text) ?? 0,
                suctionCupsCount: int.tryParse(suctionCupsController.text) ?? 0,
              );

              if (mounted) {
                Navigator.pop(context);
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stock mis à jour avec succès'), backgroundColor: Colors.green),
                  );
                  _fetchStocks();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Erreur lors de la mise à jour')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C44A6)),
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStockField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0C44A6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/login_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0x99000000),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              DashboardHeader(
                user: widget.user,
                onLogout: _logout,
                onNotificationTap: () {
                  // Navigate to notifications if needed
                },
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _fetchStocks,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _stocks.length,
                          itemBuilder: (context, index) {
                            final stock = _stocks[index];
                            return _buildTransporterCard(stock);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransporterCard(Map<String, dynamic> stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF0C44A6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stock['transporter'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _showUpdateDialog(stock),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStockItem('Barres', stock['bars_count'], Icons.view_headline, Colors.blue),
                _buildStockItem('Singles', stock['singles_count'], Icons.exposure_plus_1, Colors.orange),
                _buildStockItem('Vantouses', stock['suction_cups_count'], Icons.radio_button_checked, Colors.green),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              'Dernière mise à jour: ${stock['updated_at'].toString().split('T')[0]}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
