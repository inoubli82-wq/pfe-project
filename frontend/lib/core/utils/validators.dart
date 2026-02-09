/// ============================================
/// VALIDATORS - Form Validation Utilities
/// ============================================
library;

class Validators {
  Validators._(); // Private constructor

  /// Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  /// Phone validation regex (allows various formats)
  static final RegExp _phoneRegex = RegExp(
    r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$',
  );

  /// Validate required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName est obligatoire'
          : 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }
    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le numéro de téléphone est obligatoire';
    }
    // Remove spaces and dashes for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.length < 8 || cleanPhone.length > 15) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  /// Validate full name
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    if (value.trim().length > 100) {
      return 'Le nom est trop long';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.length < min) {
      return fieldName != null
          ? '$fieldName doit contenir au moins $min caractères'
          : 'Minimum $min caractères requis';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return fieldName != null
          ? '$fieldName ne doit pas dépasser $max caractères'
          : 'Maximum $max caractères autorisés';
    }
    return null;
  }

  /// Validate number
  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // Not required by default
    }
    if (double.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName doit être un nombre'
          : 'Veuillez entrer un nombre valide';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, [String? fieldName]) {
    final numError = number(value, fieldName);
    if (numError != null) return numError;

    if (value != null && value.isNotEmpty) {
      final num = double.parse(value);
      if (num <= 0) {
        return fieldName != null
            ? '$fieldName doit être positif'
            : 'Le nombre doit être positif';
      }
    }
    return null;
  }

  /// Combine multiple validators
  static String? combine(
      String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
