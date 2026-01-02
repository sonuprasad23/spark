import 'package:flutter/material.dart';
import '../../../../core/theme/spark_theme.dart';

/// Step indicator for onboarding flow
class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < totalSteps - 1 ? SparkSpacing.xs : 0,
            ),
            child: AnimatedContainer(
              duration: SparkDurations.fast,
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? SparkColors.primary
                    : SparkColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: SparkColors.primary.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
