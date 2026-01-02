import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../core/router/app_router.dart';

/// Splash screen with animated logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      // TODO: Check auth state and navigate accordingly
      // For now, always go to welcome
      context.go(Routes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: SparkColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: SparkColors.primaryGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: SparkShadows.glow,
                ),
                child: const Center(
                  child: Text(
                    '✨',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: SparkDurations.slow,
                    curve: SparkCurves.snappy,
                  )
                  .fade(duration: SparkDurations.normal),
              
              const SizedBox(height: SparkSpacing.lg),
              
              // App Name
              Text(
                'SPARK',
                style: SparkTypography.displayMedium.copyWith(
                  color: SparkColors.textPrimary,
                  letterSpacing: 8,
                ),
              )
                  .animate(delay: 400.ms)
                  .fade(duration: SparkDurations.normal)
                  .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: SparkSpacing.sm),
              
              // Tagline
              Text(
                'Dating that means more',
                style: SparkTypography.bodyMedium.copyWith(
                  color: SparkColors.textSecondary,
                ),
              )
                  .animate(delay: 600.ms)
                  .fade(duration: SparkDurations.normal),
            ],
          ),
        ),
      ),
    );
  }
}
