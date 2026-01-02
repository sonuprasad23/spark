import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/spark_button.dart';

/// Welcome screen - first screen after splash
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: SparkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: SparkSpacing.screenPadding,
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Animated Illustration Area
                _buildHeroSection(),
                
                const Spacer(flex: 1),
                
                // Value Propositions
                _buildValueProps(),
                
                const Spacer(flex: 2),
                
                // CTA Buttons
                _buildCTASection(context),
                
                const SizedBox(height: SparkSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Heart/Match illustration
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: SparkColors.matchGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SparkColors.primary.withOpacity(0.4),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '💖',
              style: TextStyle(fontSize: 80),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.05, 1.05),
              duration: 2.seconds,
              curve: Curves.easeInOut,
            ),
        
        const SizedBox(height: SparkSpacing.xxl),
        
        // App Name
        Text(
          'SPARK',
          style: SparkTypography.displayLarge.copyWith(
            color: SparkColors.textPrimary,
            letterSpacing: 6,
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: SparkSpacing.sm),
        
        // Tagline
        Text(
          'Dating that means more',
          style: SparkTypography.headlineSmall.copyWith(
            color: SparkColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fade(delay: 400.ms),
      ],
    );
  }

  Widget _buildValueProps() {
    final props = [
      ('🎯', 'Curated weekly matches'),
      ('💬', '7-day conversation rooms'),
      ('🛡️', 'Verified profiles only'),
    ];

    return Column(
      children: props.asMap().entries.map((entry) {
        final index = entry.key;
        final prop = entry.value;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SparkSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(prop.$1, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: SparkSpacing.md),
              Text(
                prop.$2,
                style: SparkTypography.bodyLarge.copyWith(
                  color: SparkColors.textSecondary,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fade(delay: Duration(milliseconds: 600 + (index * 150)))
            .slideX(begin: -0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Column(
      children: [
        // Primary CTA
        SparkButton(
          label: 'Get Started',
          onPressed: () => context.push(Routes.phoneLogin),
          isFullWidth: true,
        ).animate().fade(delay: 1.seconds).slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: SparkSpacing.md),
        
        // Secondary CTA
        TextButton(
          onPressed: () => context.push(Routes.phoneLogin),
          child: RichText(
            text: TextSpan(
              style: SparkTypography.bodyMedium,
              children: [
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: SparkColors.textSecondary),
                ),
                TextSpan(
                  text: 'Log In',
                  style: TextStyle(
                    color: SparkColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fade(delay: 1100.ms),
        
        const SizedBox(height: SparkSpacing.lg),
        
        // Terms
        Text(
          'By continuing, you agree to our Terms of Service\nand Privacy Policy',
          textAlign: TextAlign.center,
          style: SparkTypography.bodySmall.copyWith(
            color: SparkColors.textTertiary,
          ),
        ).animate().fade(delay: 1200.ms),
      ],
    );
  }
}
