import 'package:flutter/material.dart';
import '../../../../core/theme/spark_theme.dart';

/// Room header with match info, day counter, and actions
class RoomHeader extends StatelessWidget {
  final String matchName;
  final int dayNumber;
  final int compatibilityScore;
  final VoidCallback onBack;
  final VoidCallback onInfo;

  const RoomHeader({
    super.key,
    required this.matchName,
    required this.dayNumber,
    required this.compatibilityScore,
    required this.onBack,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SparkSpacing.sm,
        vertical: SparkSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SparkColors.surface,
        border: Border(
          bottom: BorderSide(color: SparkColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new),
            color: SparkColors.textPrimary,
            iconSize: 20,
          ),
          
          // Match avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: SparkColors.secondaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                matchName[0].toUpperCase(),
                style: SparkTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: SparkSpacing.sm),
          
          // Match info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      matchName,
                      style: SparkTypography.labelLarge.copyWith(
                        color: SparkColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: SparkSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SparkColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$compatibilityScore%',
                        style: SparkTypography.labelSmall.copyWith(
                          color: SparkColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Day $dayNumber of 7',
                  style: SparkTypography.bodySmall.copyWith(
                    color: SparkColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          // Day countdown badge
          _buildDayBadge(),
          
          // Info button
          IconButton(
            onPressed: onInfo,
            icon: const Icon(Icons.info_outline),
            color: SparkColors.textSecondary,
            iconSize: 22,
          ),
          
          // More options
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Handle menu actions
            },
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: SparkRadius.cardRadius,
            ),
            color: SparkColors.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18, color: SparkColors.textSecondary),
                    const SizedBox(width: SparkSpacing.sm),
                    Text('Report', style: SparkTypography.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 18, color: SparkColors.error),
                    const SizedBox(width: SparkSpacing.sm),
                    Text(
                      'Block',
                      style: SparkTypography.bodyMedium.copyWith(
                        color: SparkColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            icon: Icon(
              Icons.more_vert,
              color: SparkColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBadge() {
    final daysLeft = 7 - dayNumber;
    final isUrgent = daysLeft <= 2;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SparkSpacing.sm,
        vertical: SparkSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? SparkColors.warning.withOpacity(0.15)
            : SparkColors.surfaceLight,
        borderRadius: SparkRadius.chipRadius,
        border: isUrgent
            ? Border.all(color: SparkColors.warning.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: isUrgent ? SparkColors.warning : SparkColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            '$daysLeft days left',
            style: SparkTypography.labelSmall.copyWith(
              color: isUrgent ? SparkColors.warning : SparkColors.textTertiary,
              fontWeight: isUrgent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
