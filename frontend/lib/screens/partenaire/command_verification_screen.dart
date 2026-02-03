// ===========================================
// COMMAND VERIFICATION SCREEN
// ===========================================

import 'package:flutter/material.dart';

class CommandVerificationScreen extends StatefulWidget {
  const CommandVerificationScreen({Key? key}) : super(key: key);

  @override
  State<CommandVerificationScreen> createState() =>
      _CommandVerificationScreenState();
}

class _CommandVerificationScreenState extends State<CommandVerificationScreen> {
  int _nombreBarres = 6;
  int _nombreSangles = 9;
  final TextEditingController _commentaireController = TextEditingController();
  bool _estConfirme = false;

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
              // App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'AST Logitrack',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre principal
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Commande à Vérifier',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'En cours · À valider',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // CADRE PRINCIPAL
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section "En cours"
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'En cours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // Carte Export
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // En-tête Export
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Export #507',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                        Text(
                                          '27/01/2026',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Validation partenaire/client
                                    Column(
                                      children: [
                                        // Partenaire
                                        Row(
                                          children: [
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'partenaire',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Client
                                        Row(
                                          children: [
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.green,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.check,
                                                    size: 14,
                                                    color: Colors.green),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'client',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Validation attendue',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const Text(
                                                  'Depuis 2 jours',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Localisation
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.blue[700],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Marseille, France',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // Boutons Confirmer/Non confirmé
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _confirmer,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _estConfirme
                                                  ? Colors.green
                                                  : Colors.grey[100],
                                              foregroundColor: _estConfirme
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'Confirmer',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _nonConfirme,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: !_estConfirme
                                                  ? Colors.red
                                                  : Colors.grey[100],
                                              foregroundColor: !_estConfirme
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'Non confirmé !',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Section Barres
                              _buildCounterCard(
                                title: 'Nombre de Barres',
                                value: _nombreBarres,
                                onIncrement: _incrementerBarres,
                                onDecrement: _decrementerBarres,
                              ),
                              const SizedBox(height: 12),

                              // Section Sangles
                              _buildCounterCard(
                                title: 'Nombre de Sangles',
                                value: _nombreSangles,
                                onIncrement: _incrementerSangles,
                                onDecrement: _decrementerSangles,
                              ),
                              const SizedBox(height: 16),

                              // Section Commentaire
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Commentaire (optionnel)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: TextField(
                                        controller: _commentaireController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Ajouter une remarque...',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 13,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Bouton Envoyer
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _envoyer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    elevation: 1,
                                  ),
                                  child: const Text(
                                    'Envoyer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
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
            ],
          ),
        ),
      ),
    );
  }

  // Widget réutilisable pour les compteurs
  Widget _buildCounterCard({
    required String title,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                // Bouton -
                InkWell(
                  onTap: onDecrement,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border:
                          Border(right: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.remove,
                        color: Colors.grey[700],
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Nombre
                Container(
                  width: 50,
                  height: 36,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ),

                // Bouton +
                InkWell(
                  onTap: onIncrement,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border:
                          Border(left: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
