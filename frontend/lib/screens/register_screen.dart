import 'package:flutter/material.dart';
import 'package:import_export_app/screens/login_screen.dart';

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
    },
    {
      'label': 'Agent Import',
      'icon': Icons.download,
      'color': Colors.blue,
    },
    {
      'label': 'Partenaire',
      'icon': Icons.handshake,
      'color': Colors.orange,
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

      setState(() => _isLoading = true);

      await Future.delayed(const Duration(seconds: 2));

      print('=== INSCRIPTION ===');
      print('Nom: ${_fullNameController.text}');
      print('Email: ${_emailController.text}');
      print('Téléphone: $_selectedCountryCode ${_phoneController.text}');
      print('Type: $_selectedUserType');

      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // PARTIE HAUTE - IMAGE D'ARRIÈRE-PLAN
          Container(
            height: screenHeight * 0.30,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgrounds/login_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Bouton retour
                  Positioned(
                    top: 40,
                    left: 15,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // Titre
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_add,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'CRÉATION DE COMPTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rejoignez notre plateforme',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
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

          // PARTIE BASSE - FORMULAIRE
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Container(
                  width: 367,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
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
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 1. Nom & Prénom
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '1. Nom & Prénom',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue,
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
                                  color: Colors.blue, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1.5),
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
                                  color: Colors.blue, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1.5),
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
                                        color: Colors.blue, size: 20),
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
                                                      fontSize: 16)),
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
                                        color: Colors.blue, size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.blue, width: 1.5),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
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
                              '2. Vous êtes :',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Options compactes
                          Row(
                            children: _userTypes.map((type) {
                              final isSelected =
                                  _selectedUserType == type['label'];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedUserType = type['label'];
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (type['color'] as Color)
                                              .withOpacity(0.1)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? type['color'] as Color
                                            : Colors.grey[300]!,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          type['icon'] as IconData,
                                          color: type['color'] as Color,
                                          size: 22,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          type['label'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: type['color'] as Color,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // 3. Mot de passe
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '3. Mot de passe',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue,
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
                                  color: Colors.blue, size: 20),
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
                                    color: Colors.blue, width: 1.5),
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
                              '4. Confirmer le mot de passe',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue,
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
                                  color: Colors.blue, size: 20),
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
                                    color: Colors.blue, width: 1.5),
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
                                backgroundColor: Colors.blue,
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

                          // Note
                          const Text(
                            'Délai de création de compte : 2 secondes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 10),

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
                                color: Colors.blue,
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
          ),
        ],
      ),
    );
  }
}
