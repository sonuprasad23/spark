import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/spark_button.dart';

/// OTP verification screen
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length != 4) return;

    HapticFeedback.mediumImpact();
    final success = await ref.read(authProvider.notifier).verifyOtp(otp);

    if (success && mounted) {
      final authState = ref.read(authProvider);
      if (authState.needsOnboarding) {
        context.go(Routes.onboarding);
      } else {
        context.go(Routes.home);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    HapticFeedback.lightImpact();
    await ref.read(authProvider.notifier).sendOtp(widget.phoneNumber);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // OTP input theme
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: SparkTypography.displaySmall.copyWith(
        color: SparkColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: SparkColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SparkColors.cardBorder),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: SparkColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: SparkColors.primary.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: SparkColors.primary.withOpacity(0.1),
        border: Border.all(color: SparkColors.primary),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: SparkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: SparkSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: SparkSpacing.xxl),

                      // Title
                      Text(
                        'Verify your\nnumber',
                        style: SparkTypography.displaySmall.copyWith(
                          color: SparkColors.textPrimary,
                          height: 1.2,
                        ),
                      ).animate().fade().slideX(begin: -0.1, end: 0),

                      const SizedBox(height: SparkSpacing.sm),

                      // Subtitle
                      Row(
                        children: [
                          Text(
                            'Code sent to ',
                            style: SparkTypography.bodyMedium.copyWith(
                              color: SparkColors.textSecondary,
                            ),
                          ),
                          Text(
                            widget.phoneNumber,
                            style: SparkTypography.bodyMedium.copyWith(
                              color: SparkColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Change',
                              style: SparkTypography.labelMedium.copyWith(
                                color: SparkColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fade(delay: 100.ms),

                      const SizedBox(height: SparkSpacing.xxl),

                      // OTP Input
                      Center(
                        child: Pinput(
                          controller: _pinController,
                          focusNode: _focusNode,
                          length: 4,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                          showCursor: true,
                          cursor: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                width: 24,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: SparkColors.primary,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                          onCompleted: _verifyOtp,
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                        ),
                      ).animate().fade(delay: 200.ms).scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                          ),

                      const SizedBox(height: SparkSpacing.xl),

                      // Error message
                      if (authState.error != null)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(SparkSpacing.sm),
                            decoration: BoxDecoration(
                              color: SparkColors.error.withOpacity(0.1),
                              borderRadius: SparkRadius.buttonRadius,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, color: SparkColors.error, size: 18),
                                const SizedBox(width: SparkSpacing.sm),
                                Text(
                                  authState.error!,
                                  style: SparkTypography.bodySmall.copyWith(
                                    color: SparkColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Resend timer
                      Center(
                        child: _canResend
                            ? TextButton(
                                onPressed: _resendOtp,
                                child: Text(
                                  "Didn't receive code? Resend",
                                  style: SparkTypography.labelMedium.copyWith(
                                    color: SparkColors.primary,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Resend code in ',
                                    style: SparkTypography.bodyMedium.copyWith(
                                      color: SparkColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '0:${_resendSeconds.toString().padLeft(2, '0')}',
                                    style: SparkTypography.bodyMedium.copyWith(
                                      color: SparkColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ).animate().fade(delay: 300.ms),

                      const SizedBox(height: SparkSpacing.xxl),

                      // Loading indicator
                      if (isLoading)
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation(SparkColors.primary),
                                ),
                              ),
                              const SizedBox(height: SparkSpacing.md),
                              Text(
                                'Verifying...',
                                style: SparkTypography.bodyMedium.copyWith(
                                  color: SparkColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SparkSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: SparkColors.textPrimary,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
