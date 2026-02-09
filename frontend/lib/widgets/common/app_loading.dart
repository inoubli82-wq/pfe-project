import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// ============================================
/// LOADING WIDGETS - Shimmer & Indicators
/// ============================================

// ==================== LOADING INDICATOR ====================
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.size = AppDimensions.loadingSize,
    this.color,
    this.strokeWidth = 2.5,
  });

  factory AppLoadingIndicator.small() {
    return const AppLoadingIndicator(size: 16, strokeWidth: 2);
  }

  factory AppLoadingIndicator.large() {
    return const AppLoadingIndicator(size: AppDimensions.loadingSizeLarge);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

// ==================== FULL SCREEN LOADING ====================
class AppLoadingScreen extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const AppLoadingScreen({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoadingIndicator(size: 48),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== SHIMMER BASE ====================
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }
}

// ==================== SHIMMER BOX ====================
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppDimensions.radiusS,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ==================== SHIMMER CIRCLE ====================
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    this.size = AppDimensions.avatarM,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ==================== SHIMMER LIST ITEM ====================
class ShimmerListItem extends StatelessWidget {
  final bool showAvatar;
  final int lines;

  const ShimmerListItem({
    super.key,
    this.showAvatar = true,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: Row(
        children: [
          if (showAvatar) ...[
            const ShimmerCircle(size: 48),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 150, height: 16),
                const SizedBox(height: 8),
                ...List.generate(
                  lines - 1,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ShimmerBox(
                      width: index == 0 ? double.infinity : 200,
                      height: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SHIMMER CARD ====================
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 100, height: 20),
                ShimmerBox(width: 60, height: 20),
              ],
            ),
            SizedBox(height: 16),
            ShimmerBox(width: double.infinity, height: 14),
            SizedBox(height: 8),
            ShimmerBox(width: 200, height: 14),
            SizedBox(height: 16),
            Row(
              children: [
                ShimmerCircle(size: 24),
                SizedBox(width: 8),
                ShimmerBox(width: 120, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SHIMMER LIST ====================
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final bool showAvatar;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => ShimmerListItem(showAvatar: showAvatar),
    );
  }
}

// ==================== SHIMMER GRID ====================
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const ShimmerGrid({
    super.key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppDimensions.paddingM,
        crossAxisSpacing: AppDimensions.paddingM,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerBox(height: 100),
    );
  }
}
