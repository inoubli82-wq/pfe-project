import 'package:flutter/material.dart';

/// ============================================
/// EXTENSIONS - Dart Extensions for cleaner code
/// ============================================

// ==================== STRING EXTENSIONS ====================
extension StringExtensions on String {
  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(this);
  }

  /// Check if string is valid phone
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return cleaned.length >= 8 && cleaned.length <= 15;
  }

  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize each word
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Get initials
  String get initials {
    final parts = trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Check if null or empty
  bool get isNullOrEmpty => trim().isEmpty;

  /// Check if not null and not empty
  bool get isNotNullOrEmpty => trim().isNotEmpty;
}

// ==================== STRING? EXTENSIONS ====================
extension NullableStringExtensions on String? {
  /// Check if null or empty
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Check if not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.trim().isNotEmpty;

  /// Return value or default
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}

// ==================== DATETIME EXTENSIONS ====================
extension DateTimeExtensions on DateTime {
  /// Check if today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get date only (without time)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Days difference from now
  int get daysFromNow => DateTime.now().difference(this).inDays;

  /// Format as "15/01/2024"
  String get formatted {
    return '${day.toString().padLeft(2, '0')}/'
        '${month.toString().padLeft(2, '0')}/'
        '$year';
  }

  /// Format as "15/01/2024 14:30"
  String get formattedWithTime {
    return '$formatted ${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}

// ==================== INT EXTENSIONS ====================
extension IntExtensions on int {
  /// Convert to duration in seconds
  Duration get seconds => Duration(seconds: this);

  /// Convert to duration in milliseconds
  Duration get milliseconds => Duration(milliseconds: this);

  /// Convert to duration in minutes
  Duration get minutes => Duration(minutes: this);

  /// Convert to duration in hours
  Duration get hours => Duration(hours: this);

  /// Convert to duration in days
  Duration get days => Duration(days: this);

  /// Check if positive
  bool get isPositive => this > 0;

  /// Check if zero
  bool get isZero => this == 0;

  /// Check if negative
  bool get isNegative => this < 0;
}

// ==================== DOUBLE EXTENSIONS ====================
extension DoubleExtensions on double {
  /// Format with specific decimal places
  String toDecimal([int places = 2]) => toStringAsFixed(places);

  /// Format as percentage
  String toPercentage([int places = 1]) => '${toStringAsFixed(places)}%';
}

// ==================== LIST EXTENSIONS ====================
extension ListExtensions<T> on List<T> {
  /// Get first or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Safe element at index
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

// ==================== CONTEXT EXTENSIONS ====================
extension ContextExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Pop with result
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Push page
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Push and replace
  Future<T?> pushReplacement<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Push and remove all
  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }
}

// ==================== WIDGET EXTENSIONS ====================
extension WidgetExtensions on Widget {
  /// Add padding
  Widget withPadding(EdgeInsets padding) =>
      Padding(padding: padding, child: this);

  /// Add margin via Container
  Widget withMargin(EdgeInsets margin) =>
      Container(margin: margin, child: this);

  /// Center widget
  Widget get centered => Center(child: this);

  /// Expand widget
  Widget get expanded => Expanded(child: this);

  /// Make scrollable
  Widget get scrollable => SingleChildScrollView(child: this);

  /// Add tap handler
  Widget onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);

  /// Add visibility
  Widget visible(bool isVisible) => Visibility(visible: isVisible, child: this);
}
