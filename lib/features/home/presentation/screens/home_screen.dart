import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../matches/presentation/screens/matches_screen.dart';
import '../../../chat/presentation/screens/chat_room_screen.dart';

/// Home screen with bottom navigation for main app sections
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SparkColors.backgroundGradient,
        ),
        child: AnimatedSwitcher(
          duration: SparkDurations.fast,
          child: _buildCurrentScreen(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(unreadCount),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const MatchesScreen();
      case 1:
        return const _ChatsTab();
      case 2:
        return const _ProfileTab();
      default:
        return const MatchesScreen();
    }
  }

  Widget _buildBottomNav(int unreadCount) {
    return Container(
      decoration: BoxDecoration(
        color: SparkColors.surface,
        border: Border(
          top: BorderSide(
            color: SparkColors.cardBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.local_fire_department_outlined,
                activeIcon: Icons.local_fire_department,
                label: 'Matches',
                isActive: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Chats',
                isActive: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
                badge: unreadCount,
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: SparkDurations.fast,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? SparkColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive
                        ? SparkColors.primary
                        : SparkColors.textTertiary,
                    size: 24,
                  ),
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: SparkColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badge! > 9 ? '9+' : badge.toString(),
                        style: SparkTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: SparkTypography.labelSmall.copyWith(
                color: isActive
                    ? SparkColors.primary
                    : SparkColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chats Tab
class _ChatsTab extends ConsumerWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final rooms = chatState.activeRooms;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: SparkSpacing.screenPadding.copyWith(top: SparkSpacing.md),
            child: Text(
              'Connections',
              style: SparkTypography.headlineLarge.copyWith(
                color: SparkColors.textPrimary,
              ),
            ),
          ).animate().fade(),

          const SizedBox(height: SparkSpacing.md),

          if (chatState.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rooms.isEmpty)
            Expanded(child: _buildEmptyState())
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: SparkSpacing.md),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return _ChatRoomTile(
                    room: room,
                    onTap: () {
                      ref.read(chatProvider.notifier).setActiveRoom(room.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            roomId: room.id,
                            matchName: room.matchName,
                            dayNumber: room.dayNumber,
                            compatibilityScore: room.compatibilityScore,
                          ),
                        ),
                      );
                    },
                  ).animate().fade(delay: Duration(milliseconds: 50 * index));
                },
              ),
            ),
        ],
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
              child: Text('💬', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: SparkSpacing.lg),
          Text(
            'No active conversations',
            style: SparkTypography.headlineSmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ),
          const SizedBox(height: SparkSpacing.sm),
          Text(
            'When you and a match both connect,\na chat room opens here.',
            textAlign: TextAlign.center,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms);
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ConnectionRoom room;
  final VoidCallback onTap;

  const _ChatRoomTile({
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = room.daysRemaining <= 2;
    final lastMessage = room.messages.isNotEmpty
        ? room.messages.last.text
        : 'Start a conversation!';
    final lastTime = room.messages.isNotEmpty
        ? room.messages.last.timestamp
        : room.startedAt;

    return InkWell(
      onTap: onTap,
      borderRadius: SparkRadius.cardRadius,
      child: Container(
        margin: const EdgeInsets.only(bottom: SparkSpacing.sm),
        padding: const EdgeInsets.all(SparkSpacing.md),
        decoration: BoxDecoration(
          color: SparkColors.surface,
          borderRadius: SparkRadius.cardRadius,
          border: Border.all(
            color: isUrgent
                ? SparkColors.warning.withOpacity(0.3)
                : SparkColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: SparkColors.secondaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      room.matchName[0].toUpperCase(),
                      style: SparkTypography.headlineSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Day indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isUrgent ? SparkColors.warning : SparkColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SparkColors.surface, width: 2),
                    ),
                    child: Text(
                      'D${room.dayNumber}',
                      style: SparkTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: SparkSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.matchName,
                          style: SparkTypography.labelLarge.copyWith(
                            color: SparkColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(lastTime),
                        style: SparkTypography.labelSmall.copyWith(
                          color: SparkColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SparkTypography.bodySmall.copyWith(
                            color: room.unreadCount > 0
                                ? SparkColors.textPrimary
                                : SparkColors.textSecondary,
                            fontWeight: room.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (room.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: SparkColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            room.unreadCount.toString(),
                            style: SparkTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }
}

// Profile Tab
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: SparkSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: SparkSpacing.md),

            // Profile header
            Center(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: SparkColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: SparkShadows.glow,
                    ),
                    child: Center(
                      child: user?.photos.isNotEmpty == true
                          ? Text(
                              user!.name[0].toUpperCase(),
                              style: SparkTypography.displayLarge.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : const Text('👤', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: SparkSpacing.md),
                  Text(
                    user?.name ?? 'Your Name',
                    style: SparkTypography.headlineLarge.copyWith(
                      color: SparkColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${user?.age ?? 24}, ${user?.city ?? 'Bangalore'}',
                        style: SparkTypography.bodyMedium.copyWith(
                          color: SparkColors.textSecondary,
                        ),
                      ),
                      if (isPremium) ...[
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
                            'PRO',
                            style: SparkTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ).animate().fade(),

            const SizedBox(height: SparkSpacing.xxl),

            // Profile completion
            _ProfileSection(
              title: 'Profile Completion',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '75% complete',
                        style: SparkTypography.bodyMedium.copyWith(
                          color: SparkColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Add voice prompt',
                        style: SparkTypography.labelMedium.copyWith(
                          color: SparkColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SparkSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: SparkColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation(SparkColors.primary),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 100.ms),

            const SizedBox(height: SparkSpacing.md),

            // Settings list
            _ProfileSection(
              title: 'Settings',
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profile',
                    onTap: () => context.push(Routes.editProfile),
                  ),
                  _SettingsItem(
                    icon: Icons.workspace_premium_outlined,
                    label: isPremium ? 'Manage Subscription' : 'Upgrade to Pro',
                    trailing: isPremium
                        ? null
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: SparkColors.premiumGradient,
                              borderRadius: SparkRadius.chipRadius,
                            ),
                            child: Text(
                              'PRO',
                              style: SparkTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                    onTap: () => context.push(Routes.premium),
                  ),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.logout,
                    label: 'Log Out',
                    isDestructive: true,
                    onTap: () {
                      ref.read(authProvider.notifier).signOut();
                      context.go(Routes.welcome);
                    },
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms),

            const SizedBox(height: SparkSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProfileSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SparkTypography.labelLarge.copyWith(
            color: SparkColors.textSecondary,
          ),
        ),
        const SizedBox(height: SparkSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SparkSpacing.md),
          decoration: BoxDecoration(
            color: SparkColors.surface,
            borderRadius: SparkRadius.cardRadius,
            border: Border.all(color: SparkColors.cardBorder),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? SparkColors.error : SparkColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: SparkSpacing.md),
            Expanded(
              child: Text(
                label,
                style: SparkTypography.bodyLarge.copyWith(color: color),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(
                Icons.chevron_right,
                color: SparkColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
