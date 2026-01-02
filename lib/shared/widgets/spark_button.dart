import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/spark_theme.dart';

/// Reusable gradient button for SPARK app
class SparkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;
  final IconData? icon;
  final LinearGradient? gradient;

  const SparkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? SparkColors.primaryGradient;
    
    if (isOutlined) {
      return _buildOutlinedButton();
    }
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null ? effectiveGradient : null,
          color: onPressed == null ? SparkColors.surfaceLight : null,
          borderRadius: SparkRadius.buttonRadius,
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: SparkColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: SparkRadius.buttonRadius,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            onTapDown: (_) {
              HapticFeedback.lightImpact();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 20, color: Colors.white),
                            const SizedBox(width: SparkSpacing.sm),
                          ],
                          Text(
                            label,
                            style: SparkTypography.button.copyWith(
                              color: onPressed != null
                                  ? Colors.white
                                  : SparkColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: onPressed != null
                ? SparkColors.primary
                : SparkColors.surfaceLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: SparkRadius.buttonRadius,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(SparkColors.primary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: SparkSpacing.sm),
                  ],
                  Text(label, style: SparkTypography.button),
                ],
              ),
      ),
    );
  }
}

/// Social sign-in button (for Google, etc.)
class SparkSocialButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? iconPath;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SparkSocialButton({
    super.key,
    required this.label,
    this.icon,
    this.iconPath,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: SparkColors.surface,
          side: const BorderSide(color: SparkColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: SparkRadius.buttonRadius,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(icon, size: 24, color: SparkColors.textPrimary),
                  if (iconPath != null)
                    Image.asset(iconPath!, width: 24, height: 24),
                  if (icon == null && iconPath == null)
                    const Text('🔵', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: SparkSpacing.md),
                  Text(
                    label,
                    style: SparkTypography.button.copyWith(
                      color: SparkColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

