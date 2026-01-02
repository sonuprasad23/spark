import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';

/// Connection room status
enum RoomStatus {
  active,
  expired,
  connected,
  passed,
}

/// Connection room model
class ConnectionRoom {
  final String id;
  final String matchId;
  final String matchName;
  final int compatibilityScore;
  final int dayNumber;
  final DateTime startedAt;
  final DateTime expiresAt;
  final RoomStatus status;
  final List<ChatMessage> messages;
  final int unreadCount;
  final bool canExtend;
  final int extensionsUsed;

  const ConnectionRoom({
    required this.id,
    required this.matchId,
    required this.matchName,
    required this.compatibilityScore,
    required this.dayNumber,
    required this.startedAt,
    required this.expiresAt,
    this.status = RoomStatus.active,
    this.messages = const [],
    this.unreadCount = 0,
    this.canExtend = true,
    this.extensionsUsed = 0,
  });

  ConnectionRoom copyWith({
    String? id,
    String? matchId,
    String? matchName,
    int? compatibilityScore,
    int? dayNumber,
    DateTime? startedAt,
    DateTime? expiresAt,
    RoomStatus? status,
    List<ChatMessage>? messages,
    int? unreadCount,
    bool? canExtend,
    int? extensionsUsed,
  }) {
    return ConnectionRoom(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      matchName: matchName ?? this.matchName,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      dayNumber: dayNumber ?? this.dayNumber,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      canExtend: canExtend ?? this.canExtend,
      extensionsUsed: extensionsUsed ?? this.extensionsUsed,
    );
  }

  bool get isDecisionDay => dayNumber >= 7;
  int get daysRemaining => 7 - dayNumber;
}

/// Chat state
class ChatState {
  final List<ConnectionRoom> rooms;
  final bool isLoading;
  final String? error;
  final String? activeRoomId;

  const ChatState({
    this.rooms = const [],
    this.isLoading = false,
    this.error,
    this.activeRoomId,
  });

  ChatState copyWith({
    List<ConnectionRoom>? rooms,
    bool? isLoading,
    String? error,
    String? activeRoomId,
  }) {
    return ChatState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeRoomId: activeRoomId ?? this.activeRoomId,
    );
  }

  List<ConnectionRoom> get activeRooms =>
      rooms.where((r) => r.status == RoomStatus.active).toList();

  int get totalUnread =>
      activeRooms.fold(0, (sum, room) => sum + room.unreadCount);

  ConnectionRoom? get activeRoom {
    if (activeRoomId == null) return null;
    try {
      return rooms.firstWhere((r) => r.id == activeRoomId);
    } catch (_) {
      return null;
    }
  }
}

/// Chat notifier
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  /// Load all connection rooms
  Future<void> loadRooms() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Fetch from Firestore
      await Future.delayed(const Duration(seconds: 1));

      // Sample rooms
      final now = DateTime.now();
      final sampleRooms = [
        ConnectionRoom(
          id: 'room_1',
          matchId: '1',
          matchName: 'Priya',
          compatibilityScore: 87,
          dayNumber: 3,
          startedAt: now.subtract(const Duration(days: 2)),
          expiresAt: now.add(const Duration(days: 4)),
          messages: ChatMessage.sampleMessages,
          unreadCount: 2,
        ),
        ConnectionRoom(
          id: 'room_2',
          matchId: '2',
          matchName: 'Ananya',
          compatibilityScore: 82,
          dayNumber: 1,
          startedAt: now,
          expiresAt: now.add(const Duration(days: 6)),
          messages: [],
          unreadCount: 0,
        ),
      ];

      state = state.copyWith(
        rooms: sampleRooms,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Set active room
  void setActiveRoom(String roomId) {
    state = state.copyWith(activeRoomId: roomId);
    markRoomAsRead(roomId);
  }

  /// Clear active room
  void clearActiveRoom() {
    state = state.copyWith(activeRoomId: null);
  }

  /// Mark room as read
  void markRoomAsRead(String roomId) {
    final index = state.rooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;

    final updatedRooms = List<ConnectionRoom>.from(state.rooms);
    updatedRooms[index] = updatedRooms[index].copyWith(unreadCount: 0);

    state = state.copyWith(rooms: updatedRooms);
  }

  /// Send a message
  Future<bool> sendMessage(String roomId, String text) async {
    try {
      final index = state.rooms.indexWhere((r) => r.id == roomId);
      if (index == -1) return false;

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      final updatedRooms = List<ConnectionRoom>.from(state.rooms);
      updatedRooms[index] = updatedRooms[index].copyWith(
        messages: [...updatedRooms[index].messages, newMessage],
      );

      state = state.copyWith(rooms: updatedRooms);

      // TODO: Send to Firestore
      await Future.delayed(const Duration(milliseconds: 300));

      // Update message status to sent
      final sentIndex = updatedRooms[index].messages.length - 1;
      final updatedMessages = List<ChatMessage>.from(updatedRooms[index].messages);
      updatedMessages[sentIndex] = ChatMessage(
        id: newMessage.id,
        text: newMessage.text,
        isMe: true,
        timestamp: newMessage.timestamp,
        status: MessageStatus.sent,
      );
      updatedRooms[index] = updatedRooms[index].copyWith(messages: updatedMessages);
      state = state.copyWith(rooms: updatedRooms);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Make a decision on Day 7
  Future<bool> makeDecision(String roomId, String decision) async {
    try {
      final index = state.rooms.indexWhere((r) => r.id == roomId);
      if (index == -1) return false;

      // TODO: Send decision to backend
      await Future.delayed(const Duration(seconds: 1));

      RoomStatus newStatus;
      switch (decision) {
        case 'connect':
          newStatus = RoomStatus.connected;
          break;
        case 'pass':
          newStatus = RoomStatus.passed;
          break;
        case 'extend':
          // Extend by 3 days
          final updatedRooms = List<ConnectionRoom>.from(state.rooms);
          updatedRooms[index] = updatedRooms[index].copyWith(
            dayNumber: updatedRooms[index].dayNumber - 3,
            expiresAt: updatedRooms[index].expiresAt.add(const Duration(days: 3)),
            extensionsUsed: updatedRooms[index].extensionsUsed + 1,
            canExtend: false, // Only one extension allowed
          );
          state = state.copyWith(rooms: updatedRooms);
          return true;
        default:
          return false;
      }

      final updatedRooms = List<ConnectionRoom>.from(state.rooms);
      updatedRooms[index] = updatedRooms[index].copyWith(status: newStatus);
      state = state.copyWith(rooms: updatedRooms);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final notifier = ChatNotifier();
  notifier.loadRooms();
  return notifier;
});

/// Active rooms provider
final activeRoomsProvider = Provider<List<ConnectionRoom>>((ref) {
  return ref.watch(chatProvider).activeRooms;
});

/// Total unread count
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(chatProvider).totalUnread;
});

/// Active room provider
final activeRoomProvider = Provider<ConnectionRoom?>((ref) {
  return ref.watch(chatProvider).activeRoom;
});
