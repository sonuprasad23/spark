import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../widgets/match_card.dart';

/// Screen displaying weekly matches in a card stack
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final List<MatchProfile> _matches = MatchProfile.sampleMatches;
  int _currentIndex = 0;
  final Set<String> _revealedMatches = {};

  void _onReveal(MatchProfile profile) {
    setState(() {
      _revealedMatches.add(profile.id);
    });
    // TODO: Send reveal action to backend
    _showMatchDialog(profile);
  }

  void _onPass(MatchProfile profile) {
    setState(() {
      if (_currentIndex < _matches.length - 1) {
        _currentIndex++;
      }
    });
    // TODO: Send pass action to backend
  }

  void _showMatchDialog(MatchProfile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MatchSuccessDialog(
        profile: profile,
        onStartChat: () {
          Navigator.of(context).pop();
          // TODO: Navigate to chat room
        },
        onKeepBrowsing: () {
          Navigator.of(context).pop();
          setState(() {
            if (_currentIndex < _matches.length - 1) {
              _currentIndex++;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: SparkSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SparkSpacing.md),
            
            // Header
            _buildHeader(),
            
            const SizedBox(height: SparkSpacing.xl),
            
            // Match cards
            Expanded(
              child: _matches.isEmpty
                  ? _buildEmptyState()
                  : _buildMatchStack(),
            ),
            
            // Match indicators
            if (_matches.isNotEmpty) _buildIndicators(),
            
            const SizedBox(height: SparkSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Matches',
              style: SparkTypography.headlineLarge.copyWith(
                color: SparkColors.textPrimary,
              ),
            ),
            const SizedBox(height: SparkSpacing.xs),
            Text(
              'Refreshes in 3 days',
              style: SparkTypography.bodySmall.copyWith(
                color: SparkColors.textTertiary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: SparkColors.primaryGradient,
            borderRadius: SparkRadius.chipRadius,
            boxShadow: [
              BoxShadow(
                color: SparkColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${_matches.length - _currentIndex} left',
            style: SparkTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fade();
  }

  Widget _buildMatchStack() {
    if (_currentIndex >= _matches.length) {
      return _buildAllMatchesViewed();
    }

    return Center(
      child: MatchCard(
        key: ValueKey(_matches[_currentIndex].id),
        profile: _matches[_currentIndex],
        isRevealed: _revealedMatches.contains(_matches[_currentIndex].id),
        onReveal: () => _onReveal(_matches[_currentIndex]),
        onPass: () => _onPass(_matches[_currentIndex]),
      ).animate().fade().scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1, 1),
        duration: SparkDurations.normal,
        curve: SparkCurves.snappy,
      ),
    );
  }

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SparkSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_matches.length, (index) {
          final isActive = index == _currentIndex;
          final isViewed = index < _currentIndex;
          
          return AnimatedContainer(
            duration: SparkDurations.fast,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isViewed
                  ? SparkColors.success
                  : isActive
                      ? SparkColors.primary
                      : SparkColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: SparkColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔍', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: SparkSpacing.lg),
          Text(
            'No matches this week',
            style: SparkTypography.headlineSmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ),
          const SizedBox(height: SparkSpacing.sm),
          Text(
            'Complete your profile to get\nbetter matches next week',
            textAlign: TextAlign.center,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMatchesViewed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: SparkColors.secondaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SparkColors.secondary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 56)),
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: SparkDurations.slow,
            curve: SparkCurves.snappy,
          ),
          
          const SizedBox(height: SparkSpacing.xl),
          
          Text(
            'You\'ve seen all matches!',
            style: SparkTypography.headlineMedium.copyWith(
              color: SparkColors.textPrimary,
            ),
          ).animate().fade(delay: 200.ms),
          
          const SizedBox(height: SparkSpacing.sm),
          
          Text(
            'New matches arrive every Sunday.\nCheck back then!',
            textAlign: TextAlign.center,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textSecondary,
            ),
          ).animate().fade(delay: 300.ms),
          
          const SizedBox(height: SparkSpacing.xl),
          
          // Premium upsell
          Container(
            padding: const EdgeInsets.all(SparkSpacing.md),
            decoration: BoxDecoration(
              color: SparkColors.surface,
              borderRadius: SparkRadius.cardRadius,
              border: Border.all(color: SparkColors.tertiary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: SparkColors.premiumGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: SparkSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Want more matches?',
                        style: SparkTypography.labelLarge.copyWith(
                          color: SparkColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Upgrade to Pro for 10 matches/week',
                        style: SparkTypography.bodySmall.copyWith(
                          color: SparkColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: SparkColors.textTertiary,
                ),
              ],
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

/// Success dialog when user clicks Connect
class _MatchSuccessDialog extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback onStartChat;
  final VoidCallback onKeepBrowsing;

  const _MatchSuccessDialog({
    required this.profile,
    required this.onStartChat,
    required this.onKeepBrowsing,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(SparkSpacing.lg),
        decoration: BoxDecoration(
          color: SparkColors.surface,
          borderRadius: SparkRadius.modalRadius,
          border: Border.all(color: SparkColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: SparkColors.matchGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 40)),
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
              'Connection Request Sent!',
              style: SparkTypography.headlineMedium.copyWith(
                color: SparkColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: SparkSpacing.sm),
            
            Text(
              'If ${profile.name} also connects with you,\na chat room will open!',
              style: SparkTypography.bodyMedium.copyWith(
                color: SparkColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: SparkSpacing.xl),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onKeepBrowsing,
                    child: const Text('Keep Browsing'),
                  ),
                ),
                const SizedBox(width: SparkSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onKeepBrowsing,
                    child: const Text('Got it!'),
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
