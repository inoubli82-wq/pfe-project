// ===========================================
// REUSABLE BUTTON WIDGETS
// ===========================================

import 'package:flutter/material.dart';

// ===========================================
// PRIMARY BUTTON
// ===========================================
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF0C44A6),
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 3,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ===========================================
// SECONDARY BUTTON (Outlined)
// ===========================================
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? const Color(0xFF0C44A6);
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor ?? color),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor ?? color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================
// ACTION CARD BUTTON
// ===========================================
class ActionCardButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double height;
  final int? badgeCount;
  final String? backgroundImage;

  const ActionCardButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.height = 120,
    this.badgeCount,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias, // Ensure background image is clipped
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: backgroundImage != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black
                            .withValues(alpha: 0.4), // Darken for readability
                        BlendMode.darken,
                      ),
                    ),
                  )
                : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool compact =
                    constraints.maxHeight < 90 || constraints.maxWidth < 360;
                final double boxSize = compact ? 40 : 60;
                final double iconSize = compact ? 22 : 35;
                final double horizontalSpace = compact ? 10 : 20;
                final EdgeInsets contentPadding = EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 20,
                  vertical: compact ? 8 : 20,
                );

                return Padding(
                  padding: contentPadding,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: boxSize,
                            height: boxSize,
                            decoration: BoxDecoration(
                              color: backgroundImage != null
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              size: iconSize,
                              color: backgroundImage != null
                                  ? Colors.white
                                  : color,
                            ),
                          ),
                          if (badgeCount != null && badgeCount! > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: EdgeInsets.all(compact ? 4 : 6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  badgeCount! > 99 ? '99+' : '$badgeCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 8 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: horizontalSpace),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: compact ? 15 : 18,
                                fontWeight: FontWeight.bold,
                                color: backgroundImage != null
                                    ? Colors.white
                                    : color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle.isNotEmpty && !compact) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: backgroundImage != null
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: backgroundImage != null
                            ? Colors.white.withValues(alpha: 0.8)
                            : color,
                        size: compact ? 14 : 16,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================
// ICON BUTTON WITH BADGE
// ===========================================
class IconButtonWithBadge extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? badgeColor;
  final double iconSize;

  const IconButtonWithBadge({
    super.key,
    required this.icon,
    required this.badgeCount,
    required this.onPressed,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, color: iconColor ?? Colors.white, size: iconSize),
          onPressed: onPressed,
        ),
        if (badgeCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// ===========================================
// APPROVE/REJECT BUTTONS
// ===========================================
class ApprovalButtons extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isLoading;

  const ApprovalButtons({
    super.key,
    required this.onApprove,
    required this.onReject,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onApprove,
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Approuver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onReject,
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Refuser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
