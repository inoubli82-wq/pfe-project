import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// ============================================
/// CUSTOM BUTTON - Reusable Button Widget
/// ============================================

enum AppButtonType { primary, secondary, outline, text, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? width;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.padding,
  });

  // Factory constructors for common button types
  factory AppButton.primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.primary,
      isLoading: isLoading,
      icon: icon,
      width: width,
    );
  }

  factory AppButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.secondary,
      isLoading: isLoading,
      icon: icon,
    );
  }

  factory AppButton.outline({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.outline,
      isLoading: isLoading,
      icon: icon,
    );
  }

  factory AppButton.danger({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.danger,
      isLoading: isLoading,
      icon: icon,
    );
  }

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeight;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLarge;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width ?? double.infinity,
      height: _height,
      child: _buildButton(isEnabled),
    );
  }

  Widget _buildButton(bool isEnabled) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white70,
            elevation: 0,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: _buildChild(Colors.white),
        );

      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: _buildChild(Colors.white),
        );

      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: BorderSide(
              color: isEnabled ? AppColors.primaryBlue : AppColors.border,
              width: 1.5,
            ),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: _buildChild(AppColors.primaryBlue),
        );

      case AppButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            padding: padding,
          ),
          child: _buildChild(AppColors.primaryBlue),
        );

      case AppButtonType.danger:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: _buildChild(Colors.white),
        );
    }
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: _fontSize,
        fontWeight: FontWeight.w600,
      ),
    );

    if (icon != null || suffixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: _fontSize + 4),
            const SizedBox(width: 8),
          ],
          textWidget,
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            Icon(suffixIcon, size: _fontSize + 4),
          ],
        ],
      );
    }

    return textWidget;
  }
}
