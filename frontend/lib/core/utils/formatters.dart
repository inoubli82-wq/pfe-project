import 'package:intl/intl.dart';

/// ============================================
/// FORMATTERS - Date, Number, & Text Formatting
/// ============================================

class Formatters {
  Formatters._(); // Private constructor

  // ==================== DATE FORMATTERS ====================

  /// Format date as "15/01/2024"
  static String dateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date as "15 janvier 2024"
  static String dateLong(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }

  /// Format date as "15 jan."
  static String dateCompact(DateTime date) {
    return DateFormat('dd MMM', 'fr_FR').format(date);
  }

  /// Format date and time as "15/01/2024 à 14:30"
  static String dateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy \'à\' HH:mm').format(dateTime);
  }

  /// Format time as "14:30"
  static String time(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format relative date (Aujourd'hui, Hier, or date)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Aujourd\'hui';
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(date); // Day name
    } else {
      return dateShort(date);
    }
  }

  /// Format time ago (Il y a 5 minutes, etc.)
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return dateShort(dateTime);
    }
  }

  /// Format days since (Depuis X jours)
  static String daysSince(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) {
      return 'Aujourd\'hui';
    } else if (days == 1) {
      return 'Depuis 1 jour';
    } else {
      return 'Depuis $days jours';
    }
  }

  // ==================== NUMBER FORMATTERS ====================

  /// Format number with thousand separators (1 234 567)
  static String number(num value) {
    return NumberFormat('#,###', 'fr_FR').format(value);
  }

  /// Format as currency (1 234,56 €)
  static String currency(num value, {String symbol = '€'}) {
    return '${NumberFormat('#,##0.00', 'fr_FR').format(value)} $symbol';
  }

  /// Format as percentage (85,5 %)
  static String percentage(num value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)} %';
  }

  /// Format compact number (1.2K, 5.4M)
  static String compact(num value) {
    return NumberFormat.compact().format(value);
  }

  /// Format with specific decimal places
  static String decimal(num value, {int places = 2}) {
    return value.toStringAsFixed(places);
  }

  // ==================== TEXT FORMATTERS ====================

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  /// Capitalize each word
  static String capitalizeEachWord(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength,
      {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Format phone number
  static String phone(String phone) {
    // Remove all non-digits
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      // French format: 06 12 34 56 78
      return digits.replaceAllMapped(
        RegExp(r'(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})'),
        (m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]} ${m[5]}',
      );
    }
    return phone; // Return as-is if not standard length
  }

  /// Format initials from name (Jean Dupont -> JD)
  static String initials(String name) {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ==================== STATUS FORMATTERS ====================

  /// Format status to French
  static String status(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'in_progress':
      case 'inprogress':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      case 'approved':
        return 'Approuvé';
      case 'rejected':
        return 'Rejeté';
      default:
        return capitalize(status);
    }
  }
}
