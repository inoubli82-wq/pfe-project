// ===========================================
// COMMAND VERIFICATION SCREEN
// ===========================================

import 'package:flutter/material.dart';
import 'package:import_export_app/models/notification_model.dart';
import 'package:intl/intl.dart';

class CommandVerificationScreen extends StatefulWidget {
  final PendingRequest request;

  const CommandVerificationScreen({Key? key, required this.request})
      : super(key: key);

  @override
  State<CommandVerificationScreen> createState() =>
      _CommandVerificationScreenState();
}

class _CommandVerificationScreenState extends State<CommandVerificationScreen> {
  int _nombreBarres = 0;
  int _nombreSangles = 0;
  final TextEditingController _commentaireController = TextEditingController();
  bool _estConfirme = false;
  int _selectedNavIndex = 0;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  void _incrementerBarres() {
    setState(() {
      _nombreBarres++;
    });
  }

  void _decrementerBarres() {
    if (_nombreBarres > 0) {
      setState(() {
        _nombreBarres--;
      });
    }
  }

  void _incrementerSangles() {
    setState(() {
      _nombreSangles++;
    });
  }

  void _decrementerSangles() {
    if (_nombreSangles > 0) {
      setState(() {
        _nombreSangles--;
      });
    }
  }

  void _confirmer() {
    setState(() {
      _estConfirme = true;
    });
    _showSnackBar('Commande confirmée !');
  }

  void _nonConfirme() {
    setState(() {
      _estConfirme = false;
    });
    _showSnackBar('Commande non confirmée');
  }

  int _getDaysSinceCreation() {
    return DateTime.now().difference(widget.request.createdAt).inDays;
  }

  void _envoyer() {
    String message = '✅ Données envoyées !\n';
    message += '• Barres: $_nombreBarres\n';
    message += '• Sangles: $_nombreSangles\n';
    if (_commentaireController.text.isNotEmpty) {
      message += '• Commentaire: ${_commentaireController.text}';
    }

    _showDialog('Succès', message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgrounds/login_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Color(0xFF0C44A6), size: 22),
                        ),
                        Expanded(
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'AST',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Logitrack',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.blue[900],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Title Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Commande à Vérifier',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'En cours · À valider',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content Card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En cours badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time,
                              color: Colors.orange[700], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'En cours',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Export Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.request.typeDisplayName} #${widget.request.id}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy')
                                .format(widget.request.date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Transporter row (if available)
                    if (widget.request.transporter != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined,
                                color: Colors.grey[500], size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.request.transporter!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Trailer number row
                    Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'N° Remorque: ${widget.request.trailerNumber}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Client/Supplier row with validation info
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.request.entityName,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Icon(Icons.access_time,
                            color: Colors.orange[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Validation attendue',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange[600], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Depuis ${_getDaysSinceCreation()}\njours',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[600],
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Location row
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          widget.request.country,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _confirmer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _estConfirme
                                  ? const Color(0xFF0D47A1)
                                  : const Color(0xFF0D47A1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Confirmer',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nonConfirme,
                            icon: const Icon(Icons.warning_amber_rounded,
                                size: 18),
                            label: const Text(
                              'Non confirmé',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Counter - Barres
                    _buildCounterRow(
                      title: 'Nombre de',
                      boldTitle: 'Barres',
                      value: _nombreBarres,
                      onIncrement: _incrementerBarres,
                      onDecrement: _decrementerBarres,
                    ),
                    const SizedBox(height: 16),

                    // Counter - Sangles
                    _buildCounterRow(
                      title: 'Nombre de',
                      boldTitle: 'Sangles',
                      value: _nombreSangles,
                      onIncrement: _incrementerSangles,
                      onDecrement: _decrementerSangles,
                    ),
                    const SizedBox(height: 24),

                    // Commentaire Section
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                        children: const [
                          TextSpan(
                            text: 'Commentaire ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '(optionnel)',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _commentaireController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Ajouter une remarque...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Envoyer Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _envoyer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Envoyer',
                          style: TextStyle(
                            color: Colors.white,
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

          // Bottom Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home,
                      isSelected: _selectedNavIndex == 0,
                      onTap: () => setState(() => _selectedNavIndex = 0),
                    ),
                    _buildNavItemWithBadge(
                      icon: Icons.description_outlined,
                      badgeCount: 3,
                      isSelected: _selectedNavIndex == 1,
                      onTap: () => setState(() => _selectedNavIndex = 1),
                    ),
                    _buildNavItem(
                      icon: Icons.chat_bubble_outline,
                      isSelected: _selectedNavIndex == 2,
                      onTap: () => setState(() => _selectedNavIndex = 2),
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      isSelected: _selectedNavIndex == 3,
                      onTap: () => setState(() => _selectedNavIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String boldTitle,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            children: [
              TextSpan(text: '$title '),
              TextSpan(
                text: boldTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onDecrement,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      bottomLeft: Radius.circular(7),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '–',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onIncrement,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[400],
          size: 26,
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge({
    required IconData icon,
    required int badgeCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[400],
              size: 26,
            ),
            if (badgeCount > 0)
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
