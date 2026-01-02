import 'package:flutter/material.dart';
import '../../../../core/theme/spark_theme.dart';
import '../screens/chat_room_screen.dart';

/// Message bubble widget
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  
  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isMe ? 48 : 0,
        right: message.isMe ? 0 : 48,
        bottom: SparkSpacing.sm,
      ),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SparkSpacing.md,
                vertical: SparkSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: message.isMe
                    ? SparkColors.primary
                    : SparkColors.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isMe ? 16 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: SparkTypography.bodyMedium.copyWith(
                  color: message.isMe
                      ? Colors.white
                      : SparkColors.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Timestamp and status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: SparkTypography.labelSmall.copyWith(
                    color: SparkColors.textTertiary,
                  ),
                ),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = SparkColors.textTertiary;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = SparkColors.textTertiary;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = SparkColors.textTertiary;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = SparkColors.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = SparkColors.error;
        break;
    }
    
    return Icon(icon, size: 14, color: color);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
