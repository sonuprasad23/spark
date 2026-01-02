import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../shared/widgets/spark_button.dart';

/// Match card widget for displaying potential matches
class MatchCard extends StatefulWidget {
  final MatchProfile profile;
  final VoidCallback onReveal;
  final VoidCallback onPass;
  final bool isRevealed;
  
  const MatchCard({
    super.key,
    required this.profile,
    required this.onReveal,
    required this.onPass,
    this.isRevealed = false,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipped = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SparkDurations.slow,
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _flipCard() {
    HapticFeedback.mediumImpact();
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isRevealed ? null : _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.14159;
          final isBack = angle > 1.5708;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildRevealedCard(),
                  )
                : _buildMysteryCard(),
          );
        },
      ),
    );
  }
  
  Widget _buildMysteryCard() {
    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        gradient: SparkColors.matchGradient,
        borderRadius: SparkRadius.cardRadius,
        boxShadow: SparkShadows.large,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: SparkRadius.cardRadius,
              child: CustomPaint(
                painter: _MysteryPatternPainter(),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(SparkSpacing.lg),
            child: Column(
              children: [
                const Spacer(),
                
                // Mystery avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Text('?', style: TextStyle(fontSize: 64, color: Colors.white)),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                      duration: 1500.ms,
                    ),
                
                const SizedBox(height: SparkSpacing.lg),
                
                // Compatibility score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SparkSpacing.md,
                    vertical: SparkSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: SparkRadius.chipRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: SparkSpacing.xs),
                      Text(
                        '${widget.profile.compatibilityScore}% Compatible',
                        style: SparkTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Tap to reveal hint
                Text(
                  'Tap to reveal',
                  style: SparkTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.5, end: 1.0, duration: 1.seconds),
                
                const SizedBox(height: SparkSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRevealedCard() {
    final profile = widget.profile;
    
    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        color: SparkColors.cardBackground,
        borderRadius: SparkRadius.cardRadius,
        border: Border.all(color: SparkColors.cardBorder),
        boxShadow: SparkShadows.medium,
      ),
      child: Column(
        children: [
          // Photo section
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Profile photo placeholder
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          SparkColors.secondary.withOpacity(0.3),
                          SparkColors.primary.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            profile.name[0].toUpperCase(),
                            style: SparkTypography.displayLarge.copyWith(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 72,
                            ),
                          ),
                          if (profile.isVerified)
                            Container(
                              margin: const EdgeInsets.only(top: SparkSpacing.sm),
                              padding: const EdgeInsets.symmetric(
                                horizontal: SparkSpacing.sm,
                                vertical: SparkSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: SparkColors.success.withOpacity(0.2),
                                borderRadius: SparkRadius.chipRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: SparkColors.success,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: SparkTypography.labelSmall.copyWith(
                                      color: SparkColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          SparkColors.cardBackground,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Compatibility badge
                Positioned(
                  top: SparkSpacing.md,
                  right: SparkSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SparkSpacing.sm,
                      vertical: SparkSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: SparkColors.primaryGradient,
                      borderRadius: SparkRadius.chipRadius,
                    ),
                    child: Text(
                      '${profile.compatibilityScore}%',
                      style: SparkTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Info section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(SparkSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Age
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.name}, ${profile.age}',
                          style: SparkTypography.headlineMedium.copyWith(
                            color: SparkColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: SparkSpacing.xs),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: SparkColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.city} • ${profile.distance} km away',
                        style: SparkTypography.bodySmall.copyWith(
                          color: SparkColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Pass button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onPass,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: SparkColors.cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Pass'),
                        ),
                      ),
                      
                      const SizedBox(width: SparkSpacing.md),
                      
                      // Connect button
                      Expanded(
                        flex: 2,
                        child: SparkButton(
                          label: 'Connect',
                          onPressed: widget.onReveal,
                          isFullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mystery pattern painter for unrevealed cards
class _MysteryPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Model for match profile data
class MatchProfile {
  final String id;
  final String name;
  final int age;
  final String city;
  final int distance;
  final int compatibilityScore;
  final bool isVerified;
  final List<String> photos;
  final String bio;
  final List<String> interests;
  
  const MatchProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.distance,
    required this.compatibilityScore,
    this.isVerified = false,
    this.photos = const [],
    this.bio = '',
    this.interests = const [],
  });
  
  // Sample data for testing
  static List<MatchProfile> get sampleMatches => [
    const MatchProfile(
      id: '1',
      name: 'Priya',
      age: 24,
      city: 'Bangalore',
      distance: 5,
      compatibilityScore: 87,
      isVerified: true,
      interests: ['Travel', 'Photography', 'Cooking'],
    ),
    const MatchProfile(
      id: '2',
      name: 'Ananya',
      age: 23,
      city: 'Bangalore',
      distance: 8,
      compatibilityScore: 82,
      isVerified: true,
      interests: ['Reading', 'Music', 'Fitness'],
    ),
    const MatchProfile(
      id: '3',
      name: 'Ishita',
      age: 25,
      city: 'Bangalore',
      distance: 12,
      compatibilityScore: 79,
      isVerified: false,
      interests: ['Art', 'Movies', 'Yoga'],
    ),
    const MatchProfile(
      id: '4',
      name: 'Meera',
      age: 22,
      city: 'Bangalore',
      distance: 3,
      compatibilityScore: 91,
      isVerified: true,
      interests: ['Dancing', 'Food', 'Travel'],
    ),
    const MatchProfile(
      id: '5',
      name: 'Kavya',
      age: 24,
      city: 'Bangalore',
      distance: 15,
      compatibilityScore: 76,
      isVerified: true,
      interests: ['Books', 'Coffee', 'Hiking'],
    ),
  ];
}
