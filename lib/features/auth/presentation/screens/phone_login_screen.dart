import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/spark_button.dart';

/// Phone number login screen
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  String _countryCode = '+91';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(' ', '');
    setState(() {
      _isValid = phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone);
    });
  }

  void _formatPhone(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length <= 10) {
      String formatted = digitsOnly;
      if (digitsOnly.length > 5) {
        formatted = '${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5)}';
      }
      if (formatted != value) {
        _phoneController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  Future<void> _sendOtp() async {
    if (!_isValid) return;

    HapticFeedback.mediumImpact();
    final phoneNumber = '$_countryCode${_phoneController.text.replaceAll(' ', '')}';
    
    final success = await ref.read(authProvider.notifier).sendOtp(phoneNumber);
    
    if (success && mounted) {
      context.push(Routes.otpVerification, extra: phoneNumber);
    }
  }

  Future<void> _signInWithGoogle() async {
    HapticFeedback.mediumImpact();
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    
    if (success && mounted) {
      final authState = ref.read(authProvider);
      if (authState.needsOnboarding) {
        context.go(Routes.onboarding);
      } else {
        context.go(Routes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
                        "What's your\nphone number?",
                        style: SparkTypography.displaySmall.copyWith(
                          color: SparkColors.textPrimary,
                          height: 1.2,
                        ),
                      ).animate().fade().slideX(begin: -0.1, end: 0),

                      const SizedBox(height: SparkSpacing.sm),

                      Text(
                        "We'll send you a verification code",
                        style: SparkTypography.bodyMedium.copyWith(
                          color: SparkColors.textSecondary,
                        ),
                      ).animate().fade(delay: 100.ms),

                      const SizedBox(height: SparkSpacing.xxl),

                      // Phone input
                      _buildPhoneInput(),

                      const SizedBox(height: SparkSpacing.md),

                      // Error message
                      if (authState.error != null)
                        Container(
                          padding: const EdgeInsets.all(SparkSpacing.sm),
                          decoration: BoxDecoration(
                            color: SparkColors.error.withOpacity(0.1),
                            borderRadius: SparkRadius.buttonRadius,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: SparkColors.error, size: 18),
                              const SizedBox(width: SparkSpacing.sm),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: SparkTypography.bodySmall.copyWith(
                                    color: SparkColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Privacy note
                      Text(
                        "We only use your number for verification.\nIt won't be shared with anyone.",
                        style: SparkTypography.bodySmall.copyWith(
                          color: SparkColors.textTertiary,
                        ),
                      ).animate().fade(delay: 300.ms),

                      const SizedBox(height: SparkSpacing.xxl),

                      // Send OTP button
                      SparkButton(
                        label: 'Send OTP',
                        onPressed: _isValid && !isLoading ? _sendOtp : null,
                        isFullWidth: true,
                        isLoading: isLoading,
                      ).animate().fade(delay: 400.ms),

                      const SizedBox(height: SparkSpacing.xl),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: SparkColors.cardBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: SparkSpacing.md),
                            child: Text(
                              'or',
                              style: SparkTypography.bodySmall.copyWith(
                                color: SparkColors.textTertiary,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: SparkColors.cardBorder)),
                        ],
                      ).animate().fade(delay: 500.ms),

                      const SizedBox(height: SparkSpacing.xl),

                      // Google sign in
                      SparkSocialButton(
                        label: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: isLoading ? null : _signInWithGoogle,
                      ).animate().fade(delay: 600.ms),
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

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: SparkColors.surface,
        borderRadius: SparkRadius.buttonRadius,
        border: Border.all(
          color: _focusNode.hasFocus
              ? SparkColors.primary
              : SparkColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          // Country code selector
          GestureDetector(
            onTap: () => _showCountryPicker(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SparkSpacing.md,
                vertical: SparkSpacing.md + 2,
              ),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: SparkColors.cardBorder),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '🇮🇳',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: SparkSpacing.xs),
                  Text(
                    _countryCode,
                    style: SparkTypography.bodyLarge.copyWith(
                      color: SparkColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: SparkSpacing.xs),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: SparkColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Phone number input
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              style: SparkTypography.headlineSmall.copyWith(
                color: SparkColors.textPrimary,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: '98765 43210',
                hintStyle: SparkTypography.headlineSmall.copyWith(
                  color: SparkColors.textTertiary,
                  letterSpacing: 1,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SparkSpacing.md,
                  vertical: SparkSpacing.md,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: _formatPhone,
            ),
          ),

          // Clear button
          if (_phoneController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _phoneController.clear();
                _focusNode.requestFocus();
              },
              icon: Icon(
                Icons.cancel,
                color: SparkColors.textTertiary,
                size: 20,
              ),
            ),
        ],
      ),
    ).animate().fade(delay: 200.ms);
  }

  void _showCountryPicker() {
    // TODO: Show country picker modal
    // For now, only India is supported
  }
}
