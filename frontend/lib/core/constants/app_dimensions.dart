/// ============================================
/// APP DIMENSIONS - Spacing, Sizing, & Radii
/// ============================================
///
/// Usage: AppDimensions.paddingM, AppDimensions.radiusL, etc.
/// This ensures consistent spacing throughout the app.
library;

class AppDimensions {
  AppDimensions._(); // Private constructor

  // ==================== PADDING & MARGIN ====================
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // ==================== BORDER RADIUS ====================
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusRound = 100.0;

  // ==================== ICON SIZES ====================
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // ==================== BUTTON DIMENSIONS ====================
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonMinWidth = 120.0;

  // ==================== INPUT FIELD ====================
  static const double inputHeight = 52.0;
  static const double inputHeightSmall = 44.0;

  // ==================== CARD ====================
  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 8.0;
  static const double cardRadius = 12.0;

  // ==================== APP BAR ====================
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // ==================== BOTTOM NAV ====================
  static const double bottomNavHeight = 65.0;
  static const double bottomNavIconSize = 26.0;

  // ==================== AVATAR SIZES ====================
  static const double avatarXS = 24.0;
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXL = 96.0;

  // ==================== DIVIDER ====================
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;

  // ==================== LOADING INDICATOR ====================
  static const double loadingSize = 24.0;
  static const double loadingSizeLarge = 40.0;

  // ==================== MAX WIDTHS ====================
  static const double maxContentWidth = 600.0;
  static const double maxFormWidth = 400.0;
}
