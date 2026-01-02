import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../shared/widgets/spark_button.dart';

/// Decision Day screen - Day 7 of connection room
class DecisionDayScreen extends StatefulWidget {
  final String roomId;
  final String matchName;
  final int compatibilityScore;
  final int messagesExchanged;
  final bool isPremium;

  const DecisionDayScreen({
    super.key,
    required this.roomId,
    required this.matchName,
    required this.compatibilityScore,
    required this.messagesExchanged,
    this.isPremium = false,
  });

  @override
  State<DecisionDayScreen> createState() => _DecisionDayScreenState();
}

class _DecisionDayScreenState extends State<DecisionDayScreen> {
  bool _isLoading = false;
  String? _selectedDecision;

  void _onDecision(String decision) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedDecision = decision;
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (decision == 'connect') {
      _showConnectResult();
    } else if (decision == 'extend') {
      _showExtendResult();
    } else {
      _showPassResult();
    }
  }

  void _showConnectResult() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _DecisionResultSheet(
        type: 'connect',
        matchName: widget.matchName,
        onAction: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Go back to chat list
        },
      ),
    );
  }

  void _showExtendResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DecisionResultSheet(
        type: 'extend',
        matchName: widget.matchName,
        onAction: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showPassResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DecisionResultSheet(
        type: 'pass',
        matchName: widget.matchName,
        onAction: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SparkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: SparkSpacing.screenPadding,
                  child: Column(
                    children: [
                      const SizedBox(height: SparkSpacing.xl),

                      // Decision illustration
                      _buildIllustration(),

                      const SizedBox(height: SparkSpacing.xl),

                      // Stats
                      _buildStats(),

                      const SizedBox(height: SparkSpacing.xxl),

                      // Decision options
                      _buildDecisionOptions(),

                      const SizedBox(height: SparkSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(SparkSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: SparkColors.textPrimary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Decision Day',
                  style: SparkTypography.headlineSmall.copyWith(
                    color: SparkColors.textPrimary,
                  ),
                ),
                Text(
                  'Day 7 of 7',
                  style: SparkTypography.bodySmall.copyWith(
                    color: SparkColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Column(
      children: [
        // Match avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: SparkColors.matchGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SparkColors.primary.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.matchName[0].toUpperCase(),
              style: SparkTypography.displayLarge.copyWith(
                color: Colors.white,
                fontSize: 56,
              ),
            ),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: SparkDurations.slow,
              curve: SparkCurves.snappy,
            )
            .fade(),

        const SizedBox(height: SparkSpacing.lg),

        Text(
          'Time to decide',
          style: SparkTypography.headlineLarge.copyWith(
            color: SparkColors.textPrimary,
          ),
        ).animate().fade(delay: 200.ms),

        const SizedBox(height: SparkSpacing.sm),

        Text(
          'What would you like to do with\nyour connection with ${widget.matchName}?',
          textAlign: TextAlign.center,
          style: SparkTypography.bodyMedium.copyWith(
            color: SparkColors.textSecondary,
          ),
        ).animate().fade(delay: 300.ms),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(SparkSpacing.md),
      decoration: BoxDecoration(
        color: SparkColors.surface,
        borderRadius: SparkRadius.cardRadius,
        border: Border.all(color: SparkColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: '✨',
              value: '${widget.compatibilityScore}%',
              label: 'Compatible',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: SparkColors.cardBorder,
          ),
          Expanded(
            child: _StatItem(
              icon: '💬',
              value: '${widget.messagesExchanged}',
              label: 'Messages',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: SparkColors.cardBorder,
          ),
          Expanded(
            child: _StatItem(
              icon: '📅',
              value: '7',
              label: 'Days',
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 400.ms);
  }

  Widget _buildDecisionOptions() {
    return Column(
      children: [
        // Connect option
        _DecisionOption(
          title: 'Connect',
          subtitle: 'Continue chatting without time limits',
          icon: '💚',
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          ),
          isSelected: _selectedDecision == 'connect',
          isLoading: _isLoading && _selectedDecision == 'connect',
          onTap: () => _onDecision('connect'),
        ).animate().fade(delay: 500.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: SparkSpacing.md),

        // Extend option
        _DecisionOption(
          title: 'Extend',
          subtitle: widget.isPremium
              ? 'Add 3 more days to decide'
              : 'Upgrade to Pro to extend',
          icon: '⏳',
          gradient: SparkColors.premiumGradient,
          isSelected: _selectedDecision == 'extend',
          isLoading: _isLoading && _selectedDecision == 'extend',
          isLocked: !widget.isPremium,
          onTap: widget.isPremium ? () => _onDecision('extend') : _showPremiumUpsell,
        ).animate().fade(delay: 600.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: SparkSpacing.md),

        // Pass option
        _DecisionOption(
          title: 'Pass',
          subtitle: 'End the connection gracefully',
          icon: '👋',
          gradient: LinearGradient(
            colors: [SparkColors.surfaceLight, SparkColors.surfaceLighter],
          ),
          isSelected: _selectedDecision == 'pass',
          isLoading: _isLoading && _selectedDecision == 'pass',
          textColor: SparkColors.textSecondary,
          onTap: () => _showPassConfirmation(),
        ).animate().fade(delay: 700.ms).slideX(begin: -0.1, end: 0),
      ],
    );
  }

  void _showPassConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SparkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: SparkRadius.modalRadius,
        ),
        title: Text(
          'Are you sure?',
          style: SparkTypography.headlineSmall.copyWith(
            color: SparkColors.textPrimary,
          ),
        ),
        content: Text(
          'This will end your connection with ${widget.matchName}. This action cannot be undone.',
          style: SparkTypography.bodyMedium.copyWith(
            color: SparkColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: SparkColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onDecision('pass');
            },
            child: Text(
              'Yes, Pass',
              style: TextStyle(color: SparkColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumUpsell() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SparkColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(SparkSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SparkColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SparkSpacing.lg),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: SparkColors.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👑', style: TextStyle(fontSize: 40)),
              ),
            ),

            const SizedBox(height: SparkSpacing.lg),

            Text(
              'Need more time?',
              style: SparkTypography.headlineMedium.copyWith(
                color: SparkColors.textPrimary,
              ),
            ),

            const SizedBox(height: SparkSpacing.sm),

            Text(
              'Upgrade to SPARK Pro to extend your\nconnection rooms by 3 days.',
              textAlign: TextAlign.center,
              style: SparkTypography.bodyMedium.copyWith(
                color: SparkColors.textSecondary,
              ),
            ),

            const SizedBox(height: SparkSpacing.xl),

            SparkButton(
              label: 'Upgrade to Pro - ₹499/mo',
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to premium screen
              },
              isFullWidth: true,
              gradient: SparkColors.premiumGradient,
            ),

            const SizedBox(height: SparkSpacing.md),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe later',
                style: SparkTypography.labelLarge.copyWith(
                  color: SparkColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: SparkSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: SparkTypography.headlineSmall.copyWith(
            color: SparkColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: SparkTypography.labelSmall.copyWith(
            color: SparkColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _DecisionOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Gradient gradient;
  final bool isSelected;
  final bool isLoading;
  final bool isLocked;
  final Color? textColor;
  final VoidCallback onTap;

  const _DecisionOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.isSelected,
    required this.isLoading,
    this.isLocked = false,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: SparkRadius.cardRadius,
      child: AnimatedContainer(
        duration: SparkDurations.fast,
        padding: const EdgeInsets.all(SparkSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : SparkColors.surface,
          borderRadius: SparkRadius.cardRadius,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : SparkColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : SparkColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: SparkSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: SparkTypography.labelLarge.copyWith(
                          color: isSelected
                              ? Colors.white
                              : textColor ?? SparkColors.textPrimary,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: SparkSpacing.xs),
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.amber,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: SparkTypography.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : SparkColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isSelected ? Colors.white : SparkColors.primary,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : SparkColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

class _DecisionResultSheet extends StatelessWidget {
  final String type;
  final String matchName;
  final VoidCallback onAction;

  const _DecisionResultSheet({
    required this.type,
    required this.matchName,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    String emoji;
    String title;
    String message;
    String buttonText;
    Gradient gradient;

    switch (type) {
      case 'connect':
        emoji = '🎉';
        title = 'Connection request sent!';
        message = 'If $matchName also connects, you can chat\nwithout time limits!';
        buttonText = 'Got it!';
        gradient = const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
        );
        break;
      case 'extend':
        emoji = '⏳';
        title = 'Room extended!';
        message = 'You have 3 more days with $matchName.\nMake them count!';
        buttonText = 'Back to chat';
        gradient = SparkColors.premiumGradient;
        break;
      case 'pass':
      default:
        emoji = '👋';
        title = 'Connection ended';
        message = 'We hope you find your spark soon!\nNew matches coming Sunday.';
        buttonText = 'Continue';
        gradient = LinearGradient(
          colors: [SparkColors.surfaceLight, SparkColors.surfaceLighter],
        );
    }

    return Container(
      padding: const EdgeInsets.all(SparkSpacing.lg),
      decoration: BoxDecoration(
        color: SparkColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SparkColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: SparkSpacing.xl),

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: SparkDurations.slow,
                curve: SparkCurves.bounce,
              ),

          const SizedBox(height: SparkSpacing.lg),

          Text(
            title,
            style: SparkTypography.headlineMedium.copyWith(
              color: SparkColors.textPrimary,
            ),
          ),

          const SizedBox(height: SparkSpacing.sm),

          Text(
            message,
            textAlign: TextAlign.center,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),

          const SizedBox(height: SparkSpacing.xl),

          SparkButton(
            label: buttonText,
            onPressed: onAction,
            isFullWidth: true,
          ),

          const SizedBox(height: SparkSpacing.lg),
        ],
      ),
    );
  }
}
