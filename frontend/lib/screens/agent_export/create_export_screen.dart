import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class CreateExportPage extends StatefulWidget {
  const CreateExportPage({super.key});

  @override
  State<CreateExportPage> createState() => _CreateExportPageState();
}

class _CreateExportPageState extends State<CreateExportPage> {
  final _formKey = GlobalKey<FormState>();
  final _trailerNumberController = TextEditingController();
  final _clientNameController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedCountry;
  String? _selectedTransporter;
  int _barsCount = 0;
  int _singlesCount = 0;
  bool _isLoading = false;

  final List<String> _countries = [
    '🇦🇫 Afghanistan',
    '🇿🇦 Afrique du Sud',
    '🇦🇱 Albanie',
    '🇩🇿 Algérie',
    '🇩🇪 Allemagne',
    '🇦🇩 Andorre',
    '🇦🇴 Angola',
    '🇦🇬 Antigua-et-Barbuda',
    '🇸🇦 Arabie Saoudite',
    '🇦🇷 Argentine',
    '🇦🇲 Arménie',
    '🇦🇺 Australie',
    '🇦🇹 Autriche',
    '🇦🇿 Azerbaïdjan',
    '🇧🇸 Bahamas',
    '🇧🇭 Bahreïn',
    '🇧🇩 Bangladesh',
    '🇧🇧 Barbade',
    '🇧🇾 Biélorussie',
    '🇧🇪 Belgique',
    '🇧🇿 Belize',
    '🇧🇯 Bénin',
    '🇧🇹 Bhoutan',
    '🇧🇴 Bolivie',
    '🇧🇦 Bosnie-Herzégovine',
    '🇧🇼 Botswana',
    '🇧🇷 Brésil',
    '🇧🇳 Brunei',
    '🇧🇬 Bulgarie',
    '🇧🇫 Burkina Faso',
    '🇧🇮 Burundi',
    '🇰🇭 Cambodge',
    '🇨🇲 Cameroun',
    '🇨🇦 Canada',
    '🇨🇻 Cap-Vert',
    '🇨🇫 République centrafricaine',
    '🇨🇱 Chili',
    '🇨🇳 Chine',
    '🇨🇾 Chypre',
    '🇨🇴 Colombie',
    '🇰🇲 Comores',
    '🇨🇬 Congo',
    '🇨🇩 République démocratique du Congo',
    '🇰🇵 Corée du Nord',
    '🇰🇷 Corée du Sud',
    '🇨🇷 Costa Rica',
    '🇨🇮 Côte d\'Ivoire',
    '🇭🇷 Croatie',
    '🇨🇺 Cuba',
    '🇩🇰 Danemark',
    '🇩🇯 Djibouti',
    '🇩🇲 Dominique',
    '🇪🇬 Égypte',
    '🇸🇻 Salvador',
    '🇦🇪 Émirats arabes unis',
    '🇪🇨 Équateur',
    '🇪🇷 Érythrée',
    '🇪🇸 Espagne',
    '🇪🇪 Estonie',
    '🇸🇿 Eswatini',
    '🇺🇸 États-Unis',
    '🇪🇹 Éthiopie',
    '🇫🇯 Fidji',
    '🇫🇮 Finlande',
    '🇫🇷 France',
    '🇬🇦 Gabon',
    '🇬🇲 Gambie',
    '🇬🇪 Géorgie',
    '🇬🇭 Ghana',
    '🇬🇷 Grèce',
    '🇬🇩 Grenade',
    '🇬🇹 Guatemala',
    '🇬🇳 Guinée',
    '🇬🇼 Guinée-Bissau',
    '🇬🇶 Guinée équatoriale',
    '🇬🇾 Guyana',
    '🇭🇹 Haïti',
    '🇭🇳 Honduras',
    '🇭🇺 Hongrie',
    '🇮🇳 Inde',
    '🇮🇩 Indonésie',
    '🇮🇶 Irak',
    '🇮🇷 Iran',
    '🇮🇪 Irlande',
    '🇮🇸 Islande',
    '🇮🇹 Italie',
    '🇯🇲 Jamaïque',
    '🇯🇵 Japon',
    '🇯🇴 Jordanie',
    '🇰🇿 Kazakhstan',
    '🇰🇪 Kenya',
    '🇰🇬 Kirghizistan',
    '🇰🇮 Kiribati',
    '🇽🇰 Kosovo',
    '🇰🇼 Koweït',
    '🇱🇦 Laos',
    '🇱🇸 Lesotho',
    '🇱🇻 Lettonie',
    '🇱🇧 Liban',
    '🇱🇷 Liberia',
    '🇱🇾 Libye',
    '🇱🇮 Liechtenstein',
    '🇱🇹 Lituanie',
    '🇱🇺 Luxembourg',
    '🇲🇰 Macédoine du Nord',
    '🇲🇬 Madagascar',
    '🇲🇾 Malaisie',
    '🇲🇼 Malawi',
    '🇲🇻 Maldives',
    '🇲🇱 Mali',
    '🇲🇹 Malte',
    '🇲🇦 Maroc',
    '🇲🇭 Îles Marshall',
    '🇲🇺 Maurice',
    '🇲🇷 Mauritanie',
    '🇲🇽 Mexique',
    '🇫🇲 Micronésie',
    '🇲🇩 Moldavie',
    '🇲🇨 Monaco',
    '🇲🇳 Mongolie',
    '🇲🇪 Monténégro',
    '🇲🇿 Mozambique',
    '🇲🇲 Myanmar (Birmanie)',
    '🇳🇦 Namibie',
    '🇳🇷 Nauru',
    '🇳🇵 Népal',
    '🇳🇮 Nicaragua',
    '🇳🇪 Niger',
    '🇳🇬 Nigeria',
    '🇳🇴 Norvège',
    '🇳🇿 Nouvelle-Zélande',
    '🇴🇲 Oman',
    '🇺🇬 Ouganda',
    '🇺🇿 Ouzbékistan',
    '🇵🇰 Pakistan',
    '🇵🇼 Palaos',
    '🇵🇸 Palestine',
    '🇵🇦 Panama',
    '🇵🇬 Papouasie-Nouvelle-Guinée',
    '🇵🇾 Paraguay',
    '🇵🇪 Pérou',
    '🇵🇭 Philippines',
    '🇵🇱 Pologne',
    '🇵🇹 Portugal',
    '🇶🇦 Qatar',
    '🇷🇴 Roumanie',
    '🇬🇧 Royaume-Uni',
    '🇷🇺 Russie',
    '🇷🇼 Rwanda',
    '🇰🇳 Saint-Christophe-et-Niévès',
    '🇱🇨 Sainte-Lucie',
    '🇻🇨 Saint-Vincent-et-les-Grenadines',
    '🇸🇲 Saint-Marin',
    '🇸🇹 Sao Tomé-et-Principe',
    '🇸🇳 Sénégal',
    '🇷🇸 Serbie',
    '🇸🇨 Seychelles',
    '🇸🇱 Sierra Leone',
    '🇸🇬 Singapour',
    '🇸🇰 Slovaquie',
    '🇸🇮 Slovénie',
    '🇸🇴 Somalie',
    '🇸🇩 Soudan',
    '🇸🇸 Soudan du Sud',
    '🇱🇰 Sri Lanka',
    '🇸🇪 Suède',
    '🇨🇭 Suisse',
    '🇸🇷 Suriname',
    '🇸🇾 Syrie',
    '🇹🇯 Tadjikistan',
    '🇹🇿 Tanzanie',
    '🇹🇩 Tchad',
    '🇨🇿 République tchèque',
    '🇹🇭 Thaïlande',
    '🇹🇱 Timor oriental',
    '🇹🇬 Togo',
    '🇹🇴 Tonga',
    '🇹🇹 Trinité-et-Tobago',
    '🇹🇳 Tunisie',
    '🇹🇲 Turkménistan',
    '🇹🇷 Turquie',
    '🇹🇻 Tuvalu',
    '🇺🇦 Ukraine',
    '🇺🇾 Uruguay',
    '🇻🇺 Vanuatu',
    '🇻🇦 Vatican',
    '🇻🇪 Venezuela',
    '🇻🇳 Vietnam',
    '🇾🇪 Yémen',
    '🇿🇲 Zambie',
    '🇿🇼 Zimbabwe'
  ];

  final List<String> _transporters = ['Trasuniverse', 'DHL', 'AST'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date d\'embarquement'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedCountry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un pays'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedTransporter == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un transporteur'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Afficher loading
      setState(() => _isLoading = true);

      try {
        // Formater la date au format ISO
        final formattedDate = _selectedDate!.toIso8601String().split('T')[0];

        // Extraire le nom du pays sans le drapeau emoji
        final countryName = _selectedCountry!.substring(4).trim();

        debugPrint('=== NOUVEL EXPORT ===');
        debugPrint('Numéro de remorque: ${_trailerNumberController.text}');
        debugPrint('Date d\'embarquement: $formattedDate');
        debugPrint('Nom du client: ${_clientNameController.text}');
        debugPrint('Pays: $countryName');
        debugPrint('Transporteur: $_selectedTransporter');
        debugPrint('Nombre de barres: $_barsCount');
        debugPrint('Nombre de singles: $_singlesCount');

        // Appeler l'API
        final response = await ApiService.createExport(
          trailerNumber: _trailerNumberController.text.trim(),
          date: formattedDate,
          clientName: _clientNameController.text.trim(),
          country: countryName,
          transporter: _selectedTransporter,
          barsCount: _barsCount,
          singlesCount: _singlesCount,
        );

        if (!mounted) return;

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export créé avec succès !'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            Navigator.pop(
                context, true); // Retourner true pour rafraîchir la liste
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Erreur lors de la création'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Erreur création export: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion au serveur'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _trailerNumberController.dispose();
    _clientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Même image d'arrière-plan
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/backgrounds/login_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay sombre
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.4),
          ),

          // Bouton retour en haut à gauche
          Positioned(
            top: 45.0,
            left: 20.0,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF0C44A6),
                size: 24.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Formulaire en bas
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30.0,
                    spreadRadius: 5.0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Champ numéro de remorque
                      TextFormField(
                        controller: _trailerNumberController,
                        style: const TextStyle(fontSize: 16.0),
                        decoration: InputDecoration(
                          labelText: 'Numéro de remorque',
                          labelStyle: const TextStyle(
                            color: Color(0xFF4A5568),
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Ex: TR-1234-AB',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(
                            Icons.confirmation_number,
                            color: Color(0xFF0C44A6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF0C44A6),
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 20.0,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le numéro de remorque';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20.0),

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
                                  _selectedDate == null
                                      ? 'Date d\'embarquement'
                                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: _selectedDate == null
                                        ? Colors.grey[400]
                                        : Colors.black,
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

                      // Champ nom du client
                      TextFormField(
                        controller: _clientNameController,
                        style: const TextStyle(fontSize: 16.0),
                        decoration: InputDecoration(
                          labelText: 'Nom du client',
                          labelStyle: const TextStyle(
                            color: Color(0xFF4A5568),
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Entrez le nom du client',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color(0xFF0C44A6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF0C44A6),
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 20.0,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom du client';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20.0),

                      // Liste déroulante des pays
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountry,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Color(0xFF0C44A6)),
                            hint: const Text(
                              'Sélectionnez un pays',
                              style: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCountry = newValue;
                              });
                            },
                            items: _countries.map((String country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // Liste déroulante des transporteurs
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTransporter,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Color(0xFF0C44A6)),
                            hint: const Text(
                              'Sélectionnez un transporteur',
                              style: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTransporter = newValue;
                              });
                            },
                            items: _transporters.map((String transporter) {
                              return DropdownMenuItem<String>(
                                value: transporter,
                                child: Text(transporter),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25.0),

                      // Nombre de barres - Label avant le compteur
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Label
                            const Text(
                              'Nombre de barres',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A5568),
                              ),
                            ),

                            // Compteur
                            Row(
                              children: [
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                      size: 20.0,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_barsCount > 0) _barsCount--;
                                    });
                                  },
                                ),
                                Container(
                                  width: 50.0,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                        color: const Color(0xFF0C44A6)),
                                  ),
                                  child: Text(
                                    '$_barsCount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0C44A6),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.green,
                                      size: 20.0,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _barsCount++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // Nombre de singles - Label avant le compteur
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Label
                            const Text(
                              'Nombre de singles',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A5568),
                              ),
                            ),

                            // Compteur
                            Row(
                              children: [
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                      size: 20.0,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_singlesCount > 0) _singlesCount--;
                                    });
                                  },
                                ),
                                Container(
                                  width: 50.0,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                        color: const Color(0xFF0C44A6)),
                                  ),
                                  child: Text(
                                    '$_singlesCount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4299E1),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.green,
                                      size: 20.0,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _singlesCount++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      // Bouton de confirmation
                      SizedBox(
                        width: double.infinity,
                        height: 56.0,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C44A6),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF0C44A6).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 8.0,
                            shadowColor:
                                const Color(0xFF0C44A6).withOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Confirmer la création',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
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
        ],
      ),
    );
  }
}
