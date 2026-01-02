import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../shared/widgets/spark_button.dart';

/// Premium subscription screen
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'monthly';
  String _selectedTier = 'pro'; // 'plus' or 'pro'
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _pricing = {
    'plus': {
      'monthly': {'price': 199, 'period': 'month'},
      'quarterly': {'price': 499, 'period': '3 months', 'savings': 98},
      'yearly': {'price': 1499, 'period': 'year', 'savings': 889},
    },
    'pro': {
      'monthly': {'price': 499, 'period': 'month'},
      'quarterly': {'price': 1199, 'period': '3 months', 'savings': 298},
      'yearly': {'price': 3999, 'period': 'year', 'savings': 1989},
    },
  };

  void _subscribe() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    
    // TODO: Initiate Razorpay payment
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SparkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: SparkRadius.modalRadius,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: SparkColors.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 40)),
              ),
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: SparkDurations.slow,
              curve: SparkCurves.bounce,
            ),
            const SizedBox(height: SparkSpacing.lg),
            Text(
              'Welcome to SPARK $_selectedTier!',
              style: SparkTypography.headlineMedium.copyWith(
                color: SparkColors.textPrimary,
              ),
            ),
            const SizedBox(height: SparkSpacing.sm),
            Text(
              'Your premium features are now unlocked.',
              style: SparkTypography.bodyMedium.copyWith(
                color: SparkColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          SparkButton(
            label: 'Start Exploring',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            isFullWidth: true,
          ),
        ],
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
                      const SizedBox(height: SparkSpacing.lg),
                      
                      // Hero section
                      _buildHero(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Tier selector
                      _buildTierSelector(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Features
                      _buildFeatures(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Pricing plans
                      _buildPricingPlans(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Subscribe button
                      _buildSubscribeButton(),
                      
                      const SizedBox(height: SparkSpacing.md),
                      
                      // Terms
                      Text(
                        'Cancel anytime. Subscription auto-renews.',
                        style: SparkTypography.bodySmall.copyWith(
                          color: SparkColors.textTertiary,
                        ),
                      ),
                      
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
            icon: const Icon(Icons.close),
            color: SparkColors.textSecondary,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // TODO: Restore purchases
            },
            child: Text(
              'Restore',
              style: SparkTypography.labelMedium.copyWith(
                color: SparkColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: SparkColors.premiumGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text('👑', style: TextStyle(fontSize: 48)),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: SparkDurations.slow,
              curve: SparkCurves.snappy,
            ),
        
        const SizedBox(height: SparkSpacing.lg),
        
        ShaderMask(
          shaderCallback: (bounds) => SparkColors.premiumGradient.createShader(bounds),
          child: Text(
            'SPARK ${_selectedTier.toUpperCase()}',
            style: SparkTypography.displaySmall.copyWith(
              color: Colors.white,
            ),
          ),
        ).animate().fade(delay: 200.ms),
        
        const SizedBox(height: SparkSpacing.sm),
        
        Text(
          'Unlock your full dating potential',
          style: SparkTypography.bodyMedium.copyWith(
            color: SparkColors.textSecondary,
          ),
        ).animate().fade(delay: 300.ms),
      ],
    );
  }

  Widget _buildTierSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SparkColors.surfaceLight,
        borderRadius: SparkRadius.chipRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TierTab(
              title: 'Plus',
              price: '₹199',
              isSelected: _selectedTier == 'plus',
              onTap: () => setState(() => _selectedTier = 'plus'),
            ),
          ),
          Expanded(
            child: _TierTab(
              title: 'Pro',
              price: '₹499',
              isSelected: _selectedTier == 'pro',
              isPremium: true,
              onTap: () => setState(() => _selectedTier = 'pro'),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 400.ms);
  }

  Widget _buildFeatures() {
    final plusFeatures = [
      ('7 matches/week', true),
      ('See who liked you', true),
      ('Read receipts', true),
      ('1 room extension/week', true),
      ('Priority visibility', false),
      ('Rewind passes', false),
      ('Weekly boost', false),
    ];
    
    final proFeatures = [
      ('10 matches/week', true),
      ('See who liked you', true),
      ('Read receipts', true),
      ('Unlimited extensions', true),
      ('Priority visibility', true),
      ('3 rewind passes/week', true),
      ('Weekly boost', true),
    ];
    
    final features = _selectedTier == 'plus' ? plusFeatures : proFeatures;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you get',
          style: SparkTypography.headlineSmall.copyWith(
            color: SparkColors.textPrimary,
          ),
        ),
        const SizedBox(height: SparkSpacing.md),
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          
          return _FeatureRow(
            feature: feature.$1,
            isIncluded: feature.$2,
          ).animate().fade(delay: Duration(milliseconds: 500 + (index * 50)));
        }),
      ],
    );
  }

  Widget _buildPricingPlans() {
    final plans = _pricing[_selectedTier]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan',
          style: SparkTypography.headlineSmall.copyWith(
            color: SparkColors.textPrimary,
          ),
        ),
        const SizedBox(height: SparkSpacing.md),
        _PricingOption(
          title: 'Monthly',
          price: '₹${plans['monthly']['price']}',
          period: '/month',
          isSelected: _selectedPlan == 'monthly',
          onTap: () => setState(() => _selectedPlan = 'monthly'),
        ),
        const SizedBox(height: SparkSpacing.sm),
        _PricingOption(
          title: 'Quarterly',
          price: '₹${plans['quarterly']['price']}',
          period: '/3 months',
          savings: plans['quarterly']['savings'],
          isSelected: _selectedPlan == 'quarterly',
          onTap: () => setState(() => _selectedPlan = 'quarterly'),
        ),
        const SizedBox(height: SparkSpacing.sm),
        _PricingOption(
          title: 'Yearly',
          price: '₹${plans['yearly']['price']}',
          period: '/year',
          savings: plans['yearly']['savings'],
          isBestValue: true,
          isSelected: _selectedPlan == 'yearly',
          onTap: () => setState(() => _selectedPlan = 'yearly'),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    final price = _pricing[_selectedTier]![_selectedPlan]['price'];
    
    return Container(
      decoration: BoxDecoration(
        gradient: SparkColors.premiumGradient,
        borderRadius: SparkRadius.buttonRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _subscribe,
          borderRadius: SparkRadius.buttonRadius,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Subscribe for ₹$price',
                      style: SparkTypography.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TierTab extends StatelessWidget {
  final String title;
  final String price;
  final bool isSelected;
  final bool isPremium;
  final VoidCallback onTap;

  const _TierTab({
    required this.title,
    required this.price,
    required this.isSelected,
    this.isPremium = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SparkDurations.fast,
        padding: const EdgeInsets.symmetric(vertical: SparkSpacing.sm + 2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (isPremium ? SparkColors.premiumGradient : SparkColors.primaryGradient)
              : null,
          borderRadius: SparkRadius.chipRadius,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: SparkTypography.labelLarge.copyWith(
                color: isSelected ? Colors.white : SparkColors.textSecondary,
              ),
            ),
            Text(
              '$price/mo',
              style: SparkTypography.labelSmall.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : SparkColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String feature;
  final bool isIncluded;

  const _FeatureRow({
    required this.feature,
    required this.isIncluded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SparkSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isIncluded
                  ? SparkColors.success.withOpacity(0.15)
                  : SparkColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncluded ? Icons.check : Icons.close,
              size: 14,
              color: isIncluded ? SparkColors.success : SparkColors.textTertiary,
            ),
          ),
          const SizedBox(width: SparkSpacing.md),
          Text(
            feature,
            style: SparkTypography.bodyMedium.copyWith(
              color: isIncluded
                  ? SparkColors.textPrimary
                  : SparkColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingOption extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final int? savings;
  final bool isBestValue;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingOption({
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    this.isBestValue = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SparkDurations.fast,
        padding: const EdgeInsets.all(SparkSpacing.md),
        decoration: BoxDecoration(
          color: SparkColors.surface,
          borderRadius: SparkRadius.cardRadius,
          border: Border.all(
            color: isSelected ? Colors.amber : SparkColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.amber : SparkColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          gradient: SparkColors.premiumGradient,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: SparkSpacing.md),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: SparkTypography.labelLarge.copyWith(
                          color: SparkColors.textPrimary,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: SparkSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: SparkColors.premiumGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: SparkTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (savings != null)
                    Text(
                      'Save ₹$savings',
                      style: SparkTypography.bodySmall.copyWith(
                        color: SparkColors.success,
                      ),
                    ),
                ],
              ),
            ),
            
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: SparkTypography.headlineSmall.copyWith(
                    color: SparkColors.textPrimary,
                  ),
                ),
                Text(
                  period,
                  style: SparkTypography.labelSmall.copyWith(
                    color: SparkColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
