import 'package:flutter/material.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedUserType;
  String _selectedCountryCode = '+216';
  String? _selectedTransporter;

  final List<String> _transporters = [
    'DHL',
    'AST',
    'TRANSUNIVERS',
  ];

  final List<Map<String, String>> _countries = [
    {"code": "+93", "name": "Afghanistan", "flag": "🇦🇫"},
    {"code": "+27", "name": "Afrique du Sud", "flag": "🇿🇦"},
    {"code": "+355", "name": "Albanie", "flag": "🇦🇱"},
    {"code": "+213", "name": "Algérie", "flag": "🇩🇿"},
    {"code": "+49", "name": "Allemagne", "flag": "🇩🇪"},
    {"code": "+376", "name": "Andorre", "flag": "🇦🇩"},
    {"code": "+244", "name": "Angola", "flag": "🇦🇴"},
    {"code": "+54", "name": "Argentine", "flag": "🇦🇷"},
    {"code": "+374", "name": "Arménie", "flag": "🇦🇲"},
    {"code": "+61", "name": "Australie", "flag": "🇦🇺"},
    {"code": "+43", "name": "Autriche", "flag": "🇦🇹"},
    {"code": "+994", "name": "Azerbaïdjan", "flag": "🇦🇿"},
    {"code": "+32", "name": "Belgique", "flag": "🇧🇪"},
    {"code": "+229", "name": "Bénin", "flag": "🇧🇯"},
    {"code": "+975", "name": "Bhoutan", "flag": "🇧🇹"},
    {"code": "+591", "name": "Bolivie", "flag": "🇧🇴"},
    {"code": "+387", "name": "Bosnie-Herzégovine", "flag": "🇧🇦"},
    {"code": "+55", "name": "Brésil", "flag": "🇧🇷"},
    {"code": "+226", "name": "Burkina Faso", "flag": "🇧🇫"},
    {"code": "+257", "name": "Burundi", "flag": "🇧🇮"},
    {"code": "+237", "name": "Cameroun", "flag": "🇨🇲"},
    {"code": "+1", "name": "Canada", "flag": "🇨🇦"},
    {"code": "+236", "name": "République centrafricaine", "flag": "🇨🇫"},
    {"code": "+235", "name": "Tchad", "flag": "🇹🇩"},
    {"code": "+56", "name": "Chili", "flag": "🇨🇱"},
    {"code": "+86", "name": "Chine", "flag": "🇨🇳"},
    {"code": "+57", "name": "Colombie", "flag": "🇨🇴"},
    {"code": "+269", "name": "Comores", "flag": "🇰🇲"},
    {"code": "+242", "name": "Congo", "flag": "🇨🇬"},
    {
      "code": "+243",
      "name": "République démocratique du Congo",
      "flag": "🇨🇩"
    },
    {"code": "+506", "name": "Costa Rica", "flag": "🇨🇷"},
    {"code": "+225", "name": "Côte d'Ivoire", "flag": "🇨🇮"},
    {"code": "+385", "name": "Croatie", "flag": "🇭🇷"},
    {"code": "+53", "name": "Cuba", "flag": "🇨🇺"},
    {"code": "+45", "name": "Danemark", "flag": "🇩🇰"},
    {"code": "+253", "name": "Djibouti", "flag": "🇩🇯"},
    {"code": "+20", "name": "Égypte", "flag": "🇪🇬"},
    {"code": "+971", "name": "Émirats arabes unis", "flag": "🇦🇪"},
    {"code": "+34", "name": "Espagne", "flag": "🇪🇸"},
    {"code": "+1", "name": "États-Unis", "flag": "🇺🇸"},
    {"code": "+251", "name": "Éthiopie", "flag": "🇪🇹"},
    {"code": "+33", "name": "France", "flag": "🇫🇷"},
    {"code": "+241", "name": "Gabon", "flag": "🇬🇦"},
    {"code": "+220", "name": "Gambie", "flag": "🇬🇲"},
    {"code": "+995", "name": "Géorgie", "flag": "🇬🇪"},
    {"code": "+30", "name": "Grèce", "flag": "🇬🇷"},
    {"code": "+224", "name": "Guinée", "flag": "🇬🇳"},
    {"code": "+245", "name": "Guinée-Bissau", "flag": "🇬🇼"},
    {"code": "+240", "name": "Guinée équatoriale", "flag": "🇬🇶"},
    {"code": "+509", "name": "Haïti", "flag": "🇭🇹"},
    {"code": "+36", "name": "Hongrie", "flag": "🇭🇺"},
    {"code": "+91", "name": "Inde", "flag": "🇮🇳"},
    {"code": "+62", "name": "Indonésie", "flag": "🇮🇩"},
    {"code": "+39", "name": "Italie", "flag": "🇮🇹"},
    {"code": "+81", "name": "Japon", "flag": "🇯🇵"},
    {"code": "+962", "name": "Jordanie", "flag": "🇯🇴"},
    {"code": "+254", "name": "Kenya", "flag": "🇰🇪"},
    {"code": "+856", "name": "Laos", "flag": "🇱🇦"},
    {"code": "+266", "name": "Lesotho", "flag": "🇱🇸"},
    {"code": "+261", "name": "Madagascar", "flag": "🇲🇬"},
    {"code": "+265", "name": "Malawi", "flag": "🇲🇼"},
    {"code": "+223", "name": "Mali", "flag": "🇲🇱"},
    {"code": "+212", "name": "Maroc", "flag": "🇲🇦"},
    {"code": "+230", "name": "Maurice", "flag": "🇲🇺"},
    {"code": "+222", "name": "Mauritanie", "flag": "🇲🇷"},
    {"code": "+52", "name": "Mexique", "flag": "🇲🇽"},
    {"code": "+258", "name": "Mozambique", "flag": "🇲🇿"},
    {"code": "+977", "name": "Népal", "flag": "🇳🇵"},
    {"code": "+505", "name": "Nicaragua", "flag": "🇳🇮"},
    {"code": "+227", "name": "Niger", "flag": "🇳🇪"},
    {"code": "+234", "name": "Nigeria", "flag": "🇳🇬"},
    {"code": "+47", "name": "Norvège", "flag": "🇳🇴"},
    {"code": "+64", "name": "Nouvelle-Zélande", "flag": "🇳🇿"},
    {"code": "+31", "name": "Pays-Bas", "flag": "🇳🇱"},
    {"code": "+51", "name": "Pérou", "flag": "🇵🇪"},
    {"code": "+63", "name": "Philippines", "flag": "🇵🇭"},
    {"code": "+48", "name": "Pologne", "flag": "🇵🇱"},
    {"code": "+351", "name": "Portugal", "flag": "🇵🇹"},
    {"code": "+250", "name": "Rwanda", "flag": "🇷🇼"},
    {"code": "+221", "name": "Sénégal", "flag": "🇸🇳"},
    {"code": "+381", "name": "Serbie", "flag": "🇷🇸"},
    {"code": "+65", "name": "Singapour", "flag": "🇸🇬"},
    {"code": "+252", "name": "Somalie", "flag": "🇸🇴"},
    {"code": "+41", "name": "Suisse", "flag": "🇨🇭"},
    {"code": "+228", "name": "Togo", "flag": "🇹🇬"},
    {"code": "+216", "name": "Tunisie", "flag": "🇹🇳"},
    {"code": "+90", "name": "Turquie", "flag": "🇹🇷"},
    {"code": "+380", "name": "Ukraine", "flag": "🇺🇦"},
    {"code": "+44", "name": "Royaume-Uni", "flag": "🇬🇧"},
    {"code": "+58", "name": "Venezuela", "flag": "🇻🇪"},
    {"code": "+84", "name": "Viêt Nam", "flag": "🇻🇳"},
    {"code": "+260", "name": "Zambie", "flag": "🇿🇲"},
    {"code": "+263", "name": "Zimbabwe", "flag": "🇿🇼"}
  ];

  final List<Map<String, dynamic>> _userTypes = [
    {
      'label': 'Agent Export',
      'icon': Icons.upload,
      'color': Colors.green,
      'description': 'Gestion des opérations d\'exportation',
    },
    {
      'label': 'Agent Import',
      'icon': Icons.download,
      'color': const Color(0xFF0C44A6),
      'description': 'Gestion des opérations d\'importation',
    },
    {
      'label': 'Partenaire',
      'icon': Icons.handshake,
      'color': Colors.orange,
      'description': 'Client partenaire ',
    },
  ];

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!value.contains('@')) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom complet';
    }
    return null;
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner votre profil'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les mots de passe ne correspondent pas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate transporter for Partenaire
      if (_selectedUserType == 'Partenaire' && _selectedTransporter == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un transporteur'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Call the real API
        final result = await ApiService.register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          countryCode: _selectedCountryCode,
          userType: _selectedUserType!,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          transporter:
              _selectedUserType == 'Partenaire' ? _selectedTransporter : null,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Compte créé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result['message'] ?? 'Erreur lors de l\'inscription'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              // Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF0C44A6),
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // FORMULAIRE
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: 367,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Formulaire d\'inscription',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C44A6),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 1. Nom & Prénom
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ' Nom & Prénom',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF0C44A6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                hintText: 'Entrez votre nom complet',
                                hintStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.person,
                                    color: Color(0xFF0C44A6), size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF0C44A6), width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(fontSize: 15),
                              validator: _validateFullName,
                            ),

                            const SizedBox(height: 15),

                            // E-mail
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'E-mail',
                                hintStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.email,
                                    color: Color(0xFF0C44A6), size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF0C44A6), width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(fontSize: 15),
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),

                            const SizedBox(height: 15),

                            // Téléphone avec sélecteur de pays
                            Row(
                              children: [
                                // Sélecteur de pays
                                Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCountryCode,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Color(0xFF0C44A6), size: 20),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedCountryCode = newValue!;
                                        });
                                      },
                                      items: _countries.map((country) {
                                        return DropdownMenuItem<String>(
                                          value: country['code'],
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Row(
                                              children: [
                                                Text(country['flag']!,
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                                const SizedBox(width: 4),
                                                Text(country['code']!,
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Champ téléphone
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      hintText: 'Numéro de téléphone',
                                      hintStyle: const TextStyle(fontSize: 14),
                                      prefixIcon: const Icon(Icons.phone,
                                          color: Color(0xFF0C44A6), size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF0C44A6),
                                            width: 1.5),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                    keyboardType: TextInputType.phone,
                                    validator: _validatePhone,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // 2. Vous êtes :
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ' Vous êtes :',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 12, 68, 166),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Options compactes
                            Column(
                              children: _userTypes.map((type) {
                                final isSelected =
                                    _selectedUserType == type['label'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedUserType = type['label'];
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (type['color'] as Color)
                                              .withValues(alpha: 0.08)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? type['color'] as Color
                                            : Colors.grey[200]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: (type['color'] as Color)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            type['icon'] as IconData,
                                            color: type['color'] as Color,
                                            size: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                type['label'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: type['color'] as Color,
                                                ),
                                              ),
                                              if (type['description'] !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  type['description'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isSelected
                                              ? type['color'] as Color
                                              : Colors.grey[400],
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            // Transporter dropdown (only shown when Partenaire is selected)
                            if (_selectedUserType == 'Partenaire') ...[
                              const SizedBox(height: 15),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  ' Transporteur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF0C44A6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
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
                                    items:
                                        _transporters.map((String transporter) {
                                      return DropdownMenuItem<String>(
                                        value: transporter,
                                        child: Text(transporter),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),

                            // 3. Mot de passe
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ' Mot de passe',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF0C44A6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'Mot de passe',
                                hintStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.lock,
                                    color: Color(0xFF0C44A6), size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF0C44A6), width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(fontSize: 15),
                              obscureText: !_isPasswordVisible,
                              validator: _validatePassword,
                            ),

                            const SizedBox(height: 15),

                            // 4. Confirmer mot de passe
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Confirmer le mot de passe',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF0C44A6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                hintText: 'Confirmer le mot de passe',
                                hintStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Color(0xFF0C44A6), size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF0C44A6), width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(fontSize: 15),
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez confirmer votre mot de passe';
                                }
                                if (value != _passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            // Bouton Confirmer
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C44A6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Confirmer',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Lien vers connexion
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Déjà un compte ? Se connecter',
                                style: TextStyle(
                                  color: Color(0xFF0C44A6),
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
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
            ],
          ),
        ),
      ),
    );
  }
}
