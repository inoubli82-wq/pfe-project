import 'package:flutter/material.dart';
import '../../models/agent_export_data.dart';
import '../../services/api_service.dart';

class EditExportPage extends StatefulWidget {
  final AgentExportData export;

  const EditExportPage({super.key, required this.export});

  @override
  State<EditExportPage> createState() => _EditExportPageState();
}

class _EditExportPageState extends State<EditExportPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _trailerNumberController;
  late TextEditingController _clientNameController;
  late TextEditingController _notesController;

  DateTime? _selectedDate;
  String? _selectedCountry;
  String? _selectedTransporter;
  int _barsCount = 0;
  int _singlesCount = 0;
  int _suctionCupsCount = 0;
  bool _isLoading = false;

  final List<String> _countries = [
    '🇦🇫 Afghanistan', '🇿🇦 Afrique du Sud', '🇦🇱 Albanie', '🇩🇿 Algérie', '🇩🇪 Allemagne',
    '🇦🇩 Andorre', '🇦🇴 Angola', '🇦🇬 Antigua-et-Barbuda', '🇸🇦 Arabie Saoudite', '🇦🇷 Argentine',
    '🇦🇲 Arménie', '🇦🇺 Australie', '🇦🇹 Autriche', '🇦🇿 Azerbaïdjan', '🇧🇸 Bahamas',
    '🇧🇭 Bahreïn', '🇧🇩 Bangladesh', '🇧🇧 Barbade', '🇧🇾 Biélorussie', '🇧🇪 Belgique',
    '🇧🇿 Belize', '🇧🇯 Bénin', '🇧🇹 Bhoutan', '🇧🇴 Bolivie', '🇧🇦 Bosnie-Herzégovine',
    '🇧🇼 Botswana', '🇧🇷 Brésil', '🇧🇳 Brunei', '🇧🇬 Bulgarie', '🇧🇫 Burkina Faso',
    '🇧🇮 Burundi', '🇰🇭 Cambodge', '🇨🇲 Cameroun', '🇨🇦 Canada', '🇨🇻 Cap-Vert',
    '🇨🇫 République centrafricaine', '🇨🇱 Chili', '🇨🇳 Chine', '🇨🇾 Chypre', '🇨🇴 Colombie',
    '🇰🇲 Comores', '🇨🇬 Congo', '🇨🇩 République démocratique du Congo', '🇰🇵 Corée du Nord',
    '🇰🇷 Corée du Sud', '🇨🇷 Costa Rica', '🇨🇮 Côte d\'Ivoire', '🇭🇷 Croatie', '🇨🇺 Cuba',
    '🇩🇰 Danemark', '🇩🇯 Djibouti', '🇩🇲 Dominique', '🇪🇬 Égypte', '🇸🇻 Salvador',
    '🇦🇪 Émirats arabes unis', '🇪🇨 Équateur', '🇪🇷 Érythrée', '🇪🇸 Espagne', '🇪🇪 Estonie',
    '🇸🇿 Eswatini', '🇺🇸 États-Unis', '🇪🇹 Éthiopie', '🇫🇯 Fidji', '🇫🇮 Finlande', '🇫🇷 France',
    '🇬🇦 Gabon', '🇬🇲 Gambie', '🇬🇪 Géorgie', '🇬🇭 Ghana', '🇬🇷 Grèce', '🇬🇩 Grenade',
    '🇬🇹 Guatemala', '🇬🇳 Guinée', '🇬🇼 Guinée-Bissau', '🇬🇶 Guinée équatoriale', '🇬🇾 Guyana',
    '🇭🇹 Haïti', '🇭🇳 Honduras', '🇭🇺 Hongrie', '🇮🇳 Inde', '🇮🇩 Indonésie', '🇮🇶 Irak',
    '🇮🇷 Iran', '🇮🇪 Irlande', '🇮🇸 Islande', '🇮🇹 Italie', '🇯🇲 Jamaïque', '🇯🇵 Japon',
    '🇯🇴 Jordanie', '🇰🇿 Kazakhstan', '🇰🇪 Kenya', '🇰🇬 Kirghizistan', '🇰🇮 Kiribati',
    '🇽🇰 Kosovo', '🇰🇼 Koweït', '🇱🇦 Laos', '🇱🇸 Lesotho', '🇱🇻 Lettonie', '🇱🇧 Liban',
    '🇱🇷 Liberia', '🇱🇾 Libye', '🇱🇮 Liechtenstein', '🇱🇹 Lituanie', '🇱🇺 Luxembourg',
    '🇲🇰 Macédoine du Nord', '🇲🇬 Madagascar', '🇲🇾 Malaisie', '🇲🇼 Malawi', '🇲🇻 Maldives',
    '🇲🇱 Mali', '🇲🇹 Malte', '🇲🇦 Maroc', '🇲🇭 Îles Marshall', '🇲🇺 Maurice', '🇲🇷 Mauritanie',
    '🇲🇽 Mexique', '🇫🇲 Micronésie', '🇲🇩 Moldavie', '🇲🇨 Monaco', '🇲🇳 Mongolie',
    '🇲🇪 Monténégro', '🇲🇿 Mozambique', '🇲🇲 Myanmar (Birmanie)', '🇳🇦 Namibie', '🇳🇷 Nauru',
    '🇳🇵 Népal', '🇳🇮 Nicaragua', '🇳🇪 Niger', '🇳🇬 Nigeria', '🇳🇴 Norvège', '🇳🇿 Nouvelle-Zélande',
    '🇴🇲 Oman', '🇺🇬 Ouganda', '🇺🇿 Ouzbékistan', '🇵🇰 Pakistan', '🇵🇼 Palaos', '🇵🇸 Palestine',
    '🇵🇦 Panama', '🇵🇬 Papouasie-Nouvelle-Guinée', '🇵🇾 Paraguay', '🇵🇪 Pérou', '🇵🇭 Philippines',
    '🇵🇱 Pologne', '🇵🇹 Portugal', '🇶🇦 Qatar', '🇷🇴 Roumanie', '🇬🇧 Royaume-Uni', '🇷🇺 Russie',
    '🇷🇼 Rwanda', '🇰🇳 Saint-Christophe-et-Niévès', '🇱🇨 Sainte-Lucie', '🇻🇨 Saint-Vincent-et-les-Grenadines',
    '🇸🇲 Saint-Marin', '🇸🇹 Sao Tomé-et-Principe', '🇸🇳 Sénégal', '🇷🇸 Serbie', '🇸🇨 Seychelles',
    '🇸🇱 Sierra Leone', '🇸🇬 Singapour', '🇸🇰 Slovaquie', '🇸🇮 Slovénie', '🇸🇴 Somalie',
    '🇸🇩 Soudan', '🇸🇸 Soudan du Sud', '🇱🇰 Sri Lanka', '🇸🇪 Suède', '🇨🇭 Suisse', '🇸🇷 Suriname',
    '🇸🇾 Syrie', '🇹🇯 Tadjikistan', '🇹🇿 Tanzanie', '🇹🇩 Tchad', '🇨🇿 République tchèque',
    '🇹🇭 Thaïlande', '🇹🇱 Timor oriental', '🇹🇬 Togo', '🇹🇴 Tonga', '🇹🇹 Trinité-et-Tobago',
    '🇹🇳 Tunisie', '🇹🇲 Turkménistan', '🇹🇷 Turquie', '🇹🇻 Tuvalu', '🇺🇦 Ukraine', '🇺🇾 Uruguay',
    '🇻🇺 Vanuatu', '🇻🇦 Vatican', '🇻🇪 Venezuela', '🇻🇳 Vietnam', '🇾🇪 Yémen', '🇿🇲 Zambie',
    '🇿🇼 Zimbabwe'
  ];

  final List<String> _transporters = ['DHL', 'AST', 'TRANSUNIVERS'];

  late TextEditingController _barsController;
  late TextEditingController _singlesController;
  late TextEditingController _suctionCupsController;

  @override
  void initState() {
    super.initState();
    _trailerNumberController = TextEditingController(text: widget.export.trailerNumber);
    _clientNameController = TextEditingController(text: widget.export.clientName);
    _notesController = TextEditingController(text: widget.export.notes ?? '');
    _barsController = TextEditingController(text: widget.export.barsCount.toString());
    _singlesController = TextEditingController(text: widget.export.singlesCount.toString());
    _suctionCupsController = TextEditingController(text: widget.export.suctionCupsCount.toString());
    
    _selectedDate = widget.export.date;
    _barsCount = widget.export.barsCount;
    _singlesCount = widget.export.singlesCount;
    _suctionCupsCount = widget.export.suctionCupsCount;
    _selectedTransporter = widget.export.transporter;

    _barsController.addListener(() {
      setState(() {
        _barsCount = int.tryParse(_barsController.text) ?? 0;
      });
    });
    _singlesController.addListener(() {
      setState(() {
        _singlesCount = int.tryParse(_singlesController.text) ?? 0;
      });
    });
    _suctionCupsController.addListener(() {
      setState(() {
        _suctionCupsCount = int.tryParse(_suctionCupsController.text) ?? 0;
      });
    });
    
    // Try to find matching country with flag
    try {
      _selectedCountry = _countries.firstWhere(
        (c) => c.toLowerCase().contains(widget.export.country.toLowerCase()),
      );
    } catch (e) {
      _selectedCountry = null;
    }
  }

  @override
  void dispose() {
    _trailerNumberController.dispose();
    _clientNameController.dispose();
    _notesController.dispose();
    _barsController.dispose();
    _singlesController.dispose();
    _suctionCupsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une date')));
         return;
      }
      if (_selectedCountry == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un pays')));
         return;
      }
      if (_selectedTransporter == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un transporteur')));
         return;
      }

      setState(() => _isLoading = true);

      try {
        final countryName = _selectedCountry!.contains(' ') 
            ? _selectedCountry!.substring(_selectedCountry!.indexOf(' ') + 1).trim()
            : _selectedCountry!;

        final updatedData = AgentExportData(
          id: widget.export.id,
          trailerNumber: _trailerNumberController.text.trim(),
          date: _selectedDate!,
          clientName: _clientNameController.text.trim(),
          country: countryName,
          transporter: _selectedTransporter,
          barsCount: _barsCount,
          singlesCount: _singlesCount,
          suctionCupsCount: _suctionCupsCount,
          notes: _notesController.text.trim(),
        );

        final response = await ApiService.updateExport(widget.export.id!, updatedData);

        if (!mounted) return;

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export mis à jour avec succès !'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Erreur lors de la mise à jour'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion au serveur'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCounter(String label, int value, TextEditingController controller, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (value > 0) {
                    final newVal = value - 1;
                    onChanged(newVal);
                    controller.text = newVal.toString();
                  }
                },
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      onChanged(int.tryParse(val) ?? 0);
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  final newVal = value + 1;
                  onChanged(newVal);
                  controller.text = newVal.toString();
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0C44A6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) => value == null || value.isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF0C44A6)),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? 'Date d\'embarquement'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label),
          items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier Export'),
        backgroundColor: const Color(0xFF0C44A6).withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(_trailerNumberController, 'Numéro de remorque', Icons.confirmation_number),
                          const SizedBox(height: 15),
                          _buildDatePicker(),
                          const SizedBox(height: 15),
                          _buildTextField(_clientNameController, 'Nom du client', Icons.person),
                          const SizedBox(height: 15),
                          _buildDropdown('Pays', _selectedCountry, _countries, (val) => setState(() => _selectedCountry = val)),
                          const SizedBox(height: 15),
                          _buildDropdown('Transporteur', _selectedTransporter, _transporters, (val) => setState(() => _selectedTransporter = val)),
                          const SizedBox(height: 25),
                          _buildCounter('Nombre de barres', _barsCount, _barsController, (val) => setState(() => _barsCount = val)),
                          const SizedBox(height: 15),
                          _buildCounter('Nombre de singles', _singlesCount, _singlesController, (val) => setState(() => _singlesCount = val)),
                          const SizedBox(height: 15),
                          _buildCounter('Nombre de vantouses', _suctionCupsCount, _suctionCupsController, (val) => setState(() => _suctionCupsCount = val)),
                          const SizedBox(height: 20),
                          _buildTextField(_notesController, 'Notes (optionnel)', Icons.note, maxLines: 3),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C44A6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Enregistrer les modifications',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
