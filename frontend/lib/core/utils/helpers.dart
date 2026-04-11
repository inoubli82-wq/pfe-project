import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// ============================================
/// HELPERS - Utility Functions
/// ============================================

class Helpers {
  Helpers._(); // Private constructor

  // ==================== SNACKBAR HELPERS ====================

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.success, Icons.check_circle);
  }

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.error, Icons.error);
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.warning, Icons.warning);
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.info, Icons.info);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ==================== DIALOG HELPERS ====================

  /// Show loading dialog
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message ?? AppStrings.loading),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText ?? AppStrings.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    String? title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title ?? AppStrings.error),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ==================== NAVIGATION HELPERS ====================

  /// Navigate to page with fade transition
  static Future<T?> navigateTo<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Navigate and replace current page
  static Future<T?> navigateReplace<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, T>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateAndClearStack<T>(
      BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  // ==================== MISC HELPERS ====================

  /// Check if string is empty or null
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if string is not empty
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  /// Generate greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'en attente':
        return AppColors.warning;
      case 'in_progress':
      case 'inprogress':
      case 'en cours':
        return AppColors.info;
      case 'completed':
      case 'terminé':
        return AppColors.success;
      case 'cancelled':
      case 'annulé':
      case 'rejected':
      case 'rejeté':
        return AppColors.error;
      case 'approved':
      case 'approuvé':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get role color
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.adminColor;
      case 'agent export':
      case 'agentexport':
        return AppColors.exportColor;
      case 'agent import':
      case 'agentimport':
        return AppColors.importColor;
      case 'partenaire':
        return AppColors.partenaireColor;
      default:
        return AppColors.primary;
    }
  }
}
