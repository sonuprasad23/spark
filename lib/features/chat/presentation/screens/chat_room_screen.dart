import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/room_header.dart';

/// 7-Day Connection Room Chat Screen
class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String matchName;
  final int dayNumber;
  final int compatibilityScore;
  
  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.matchName,
    this.dayNumber = 1,
    this.compatibilityScore = 85,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = ChatMessage.sampleMessages;
  bool _isTyping = false;
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        isMe: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      ));
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    // TODO: Send message to backend
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: SparkDurations.normal,
          curve: Curves.easeOut,
        );
      }
    });
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
              // Room header with day counter
              RoomHeader(
                matchName: widget.matchName,
                dayNumber: widget.dayNumber,
                compatibilityScore: widget.compatibilityScore,
                onBack: () => Navigator.of(context).pop(),
                onInfo: _showRoomInfo,
              ),
              
              // Day progress indicator
              _buildDayProgress(),
              
              // Messages list
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyChat()
                    : _buildMessagesList(),
              ),
              
              // Icebreaker (if day 1 and no messages)
              if (widget.dayNumber == 1 && _messages.isEmpty)
                _buildIcebreaker(),
              
              // Chat input
              ChatInput(
                controller: _messageController,
                onSend: _sendMessage,
                onVoiceNote: _handleVoiceNote,
                voiceEnabled: widget.dayNumber >= 3, // Unlock day 3
                photoEnabled: widget.dayNumber >= 5, // Unlock day 5
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SparkSpacing.md,
        vertical: SparkSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SparkColors.surface,
        border: Border(
          bottom: BorderSide(color: SparkColors.cardBorder),
        ),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final day = index + 1;
          final isActive = day <= widget.dayNumber;
          final isCurrent = day == widget.dayNumber;
          
          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: SparkDurations.fast,
                  height: 4,
                  margin: EdgeInsets.only(right: index < 6 ? 2 : 0),
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
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'D$day',
                  style: SparkTypography.labelSmall.copyWith(
                    color: isCurrent
                        ? SparkColors.primary
                        : isActive
                            ? SparkColors.textSecondary
                            : SparkColors.textTertiary,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(SparkSpacing.md),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showTimestamp = index == 0 ||
            _messages[index - 1].timestamp.day != message.timestamp.day;
        
        return Column(
          children: [
            if (showTimestamp)
              _buildDateSeparator(message.timestamp),
            MessageBubble(
              message: message,
            ).animate().fade().slideY(
              begin: 0.1,
              end: 0,
              duration: SparkDurations.fast,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String text;
    
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      text = 'Today';
    } else if (date.day == now.day - 1) {
      text = 'Yesterday';
    } else {
      text = '${date.day}/${date.month}/${date.year}';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SparkSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SparkSpacing.md,
          vertical: SparkSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: SparkColors.surfaceLight,
          borderRadius: SparkRadius.chipRadius,
        ),
        child: Text(
          text,
          style: SparkTypography.labelSmall.copyWith(
            color: SparkColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
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
              child: Text('👋', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: SparkSpacing.lg),
          Text(
            'Say hello!',
            style: SparkTypography.headlineSmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ),
          const SizedBox(height: SparkSpacing.sm),
          Text(
            'Start a conversation with\n${widget.matchName}',
            textAlign: TextAlign.center,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms);
  }

  Widget _buildIcebreaker() {
    final icebreakers = [
      "What's the most spontaneous thing you've ever done?",
      "If you could travel anywhere tomorrow, where would you go?",
      "What's something you're passionate about that most people don't know?",
      "What does your perfect weekend look like?",
    ];
    
    final icebreaker = icebreakers[widget.roomId.hashCode % icebreakers.length];
    
    return Container(
      margin: const EdgeInsets.all(SparkSpacing.md),
      padding: const EdgeInsets.all(SparkSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SparkColors.secondary.withOpacity(0.1),
            SparkColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: SparkRadius.cardRadius,
        border: Border.all(color: SparkColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: SparkSpacing.sm),
              Text(
                'Icebreaker',
                style: SparkTypography.labelMedium.copyWith(
                  color: SparkColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: SparkSpacing.sm),
          Text(
            icebreaker,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }

  void _handleVoiceNote() {
    // TODO: Implement voice note recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice notes coming soon!')),
    );
  }

  void _showRoomInfo() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SparkColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SparkSpacing.lg),
            Text(
              'Connection Room',
              style: SparkTypography.headlineMedium.copyWith(
                color: SparkColors.textPrimary,
              ),
            ),
            const SizedBox(height: SparkSpacing.md),
            _buildInfoRow('📅', 'Day ${widget.dayNumber} of 7'),
            _buildInfoRow('✨', '${widget.compatibilityScore}% Compatible'),
            _buildInfoRow('🔓', widget.dayNumber >= 3 ? 'Voice notes unlocked' : 'Voice notes unlock Day 3'),
            _buildInfoRow('📸', widget.dayNumber >= 5 ? 'Photos unlocked' : 'Photos unlock Day 5'),
            
            const SizedBox(height: SparkSpacing.lg),
            
            Container(
              padding: const EdgeInsets.all(SparkSpacing.md),
              decoration: BoxDecoration(
                color: SparkColors.surfaceLight,
                borderRadius: SparkRadius.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⏰ Decision Day',
                    style: SparkTypography.labelLarge.copyWith(
                      color: SparkColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SparkSpacing.xs),
                  Text(
                    'On Day 7, you\'ll decide whether to connect permanently or move on.',
                    style: SparkTypography.bodySmall.copyWith(
                      color: SparkColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: SparkSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SparkSpacing.sm),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: SparkSpacing.md),
          Text(
            text,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final MessageStatus status;
  final String? voiceNoteUrl;
  final String? imageUrl;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.voiceNoteUrl,
    this.imageUrl,
  });

  static List<ChatMessage> get sampleMessages => [
    ChatMessage(
      id: '1',
      text: 'Hey! I noticed we both love traveling. Where was your last trip?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '2',
      text: 'Hi! Nice to connect! I went to Goa last month. The beaches were amazing 🏖️',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '3',
      text: 'Oh I love Goa! Did you try any local restaurants?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '4',
      text: 'Yes! Found this amazing seafood place in Baga. The fish curry was incredible',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      status: MessageStatus.delivered,
    ),
  ];
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
