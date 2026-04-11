import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'app_button.dart';

/// ============================================
/// ERROR & EMPTY WIDGETS - Reusable State Widgets
/// ============================================

// ==================== ERROR WIDGET ====================
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? iconColor;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  factory AppErrorWidget.network({
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      title: 'Erreur de connexion',
      message: AppStrings.networkError,
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }

  factory AppErrorWidget.server({
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      title: 'Erreur serveur',
      message: message ?? AppStrings.unknownError,
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }

  factory AppErrorWidget.notFound({
    String? message,
  }) {
    return AppErrorWidget(
      title: 'Non trouvé',
      message: message ?? 'L\'élément demandé n\'existe pas.',
      icon: Icons.search_off,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.outline(
                text: buttonText ?? AppStrings.retry,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== EMPTY STATE WIDGET ====================
class AppEmptyWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onAction;
  final Widget? illustration;

  const AppEmptyWidget({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.buttonText,
    this.onAction,
    this.illustration,
  });

  factory AppEmptyWidget.noData({
    String? message,
    VoidCallback? onRefresh,
  }) {
    return AppEmptyWidget(
      title: 'Aucune donnée',
      message: message ?? AppStrings.noData,
      icon: Icons.folder_open,
      buttonText: 'Actualiser',
      onAction: onRefresh,
    );
  }

  factory AppEmptyWidget.noResults({
    String? searchTerm,
  }) {
    return AppEmptyWidget(
      title: 'Aucun résultat',
      message: searchTerm != null
          ? 'Aucun résultat pour "$searchTerm"'
          : AppStrings.noResults,
      icon: Icons.search_off,
    );
  }

  factory AppEmptyWidget.noNotifications() {
    return const AppEmptyWidget(
      title: 'Pas de notifications',
      message: 'Vous n\'avez aucune notification pour le moment.',
      icon: Icons.notifications_none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null)
              illustration!
            else
              Icon(
                icon,
                size: 72,
                color: AppColors.textHint,
              ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && buttonText != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                text: buttonText!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== NO INTERNET WIDGET ====================
class AppNoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const AppNoInternetWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            const Text(
              'Pas de connexion internet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Vérifiez votre connexion internet et réessayez.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                text: 'Réessayer',
                onPressed: onRetry,
                icon: Icons.refresh,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
