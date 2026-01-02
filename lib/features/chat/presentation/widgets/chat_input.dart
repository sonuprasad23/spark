import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/spark_theme.dart';

/// Chat input widget with text field, voice note, and photo options
class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback? onVoiceNote;
  final bool voiceEnabled;
  final bool photoEnabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onVoiceNote,
    this.voiceEnabled = false,
    this.photoEnabled = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onSend() {
    if (_hasText) {
      widget.onSend(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SparkSpacing.md),
      decoration: BoxDecoration(
        color: SparkColors.surface,
        border: Border(
          top: BorderSide(color: SparkColors.cardBorder),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment options
            _buildAttachmentButton(),
            
            const SizedBox(width: SparkSpacing.sm),
            
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: SparkColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        style: SparkTypography.bodyMedium.copyWith(
                          color: SparkColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: SparkTypography.bodyMedium.copyWith(
                            color: SparkColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SparkSpacing.md,
                            vertical: SparkSpacing.sm + 2,
                          ),
                        ),
                      ),
                    ),
                    
                    // Emoji button
                    IconButton(
                      onPressed: () {
                        // TODO: Open emoji picker
                      },
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: SparkColors.textTertiary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: SparkSpacing.sm),
            
            // Send / Voice button
            AnimatedSwitcher(
              duration: SparkDurations.fast,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _hasText
                  ? _buildSendButton()
                  : _buildVoiceButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'photo' && !widget.photoEnabled) {
          _showLockedFeature('Photos unlock on Day 5');
        } else if (value == 'photo') {
          // TODO: Open photo picker
        }
      },
      offset: const Offset(0, -120),
      shape: RoundedRectangleBorder(
        borderRadius: SparkRadius.cardRadius,
      ),
      color: SparkColors.surface,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'photo',
          child: Row(
            children: [
              Icon(
                Icons.photo_outlined,
                color: widget.photoEnabled
                    ? SparkColors.textPrimary
                    : SparkColors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: SparkSpacing.sm),
              Text(
                'Photo',
                style: SparkTypography.bodyMedium.copyWith(
                  color: widget.photoEnabled
                      ? SparkColors.textPrimary
                      : SparkColors.textTertiary,
                ),
              ),
              if (!widget.photoEnabled) ...[
                const Spacer(),
                Icon(
                  Icons.lock_outline,
                  color: SparkColors.textTertiary,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: SparkColors.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: SparkColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _onSend,
      child: Container(
        key: const ValueKey('send'),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: SparkColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: SparkColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTap: () {
        if (!widget.voiceEnabled) {
          _showLockedFeature('Voice notes unlock on Day 3');
        } else {
          HapticFeedback.mediumImpact();
          widget.onVoiceNote?.call();
        }
      },
      child: Container(
        key: const ValueKey('voice'),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: widget.voiceEnabled
              ? SparkColors.surfaceLight
              : SparkColors.surfaceLight.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.mic_outlined,
          color: widget.voiceEnabled
              ? SparkColors.textSecondary
              : SparkColors.textTertiary,
          size: 22,
        ),
      ),
    );
  }

  void _showLockedFeature(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 18),
            const SizedBox(width: SparkSpacing.sm),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: SparkColors.surfaceLighter,
      ),
    );
  }
}
