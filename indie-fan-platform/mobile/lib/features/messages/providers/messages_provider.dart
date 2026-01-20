import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/demo_data_service.dart';
import '../models/message_model.dart';

/// 채팅방 목록 상태
class ChatRoomsState {
  final List<ChatRoom> chatRooms;
  final bool isLoading;

  const ChatRoomsState({
    this.chatRooms = const [],
    this.isLoading = false,
  });

  ChatRoomsState copyWith({
    List<ChatRoom>? chatRooms,
    bool? isLoading,
  }) {
    return ChatRoomsState(
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalUnreadCount =>
      chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
}

/// 채팅방 목록 Notifier
class ChatRoomsNotifier extends StateNotifier<ChatRoomsState> {
  ChatRoomsNotifier() : super(const ChatRoomsState());

  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      chatRooms: DemoDataService.demoChatRooms,
      isLoading: false,
    );
  }

  void markAsRead(String chatRoomId) {
    final updatedRooms = state.chatRooms.map((room) {
      if (room.id == chatRoomId) {
        return ChatRoom(
          id: room.id,
          artistId: room.artistId,
          artistName: room.artistName,
          artistImage: room.artistImage,
          lastMessage: room.lastMessage,
          lastMessageAt: room.lastMessageAt,
          unreadCount: 0,
          replyCount: room.replyCount,
          maxReplies: room.maxReplies,
        );
      }
      return room;
    }).toList();

    state = state.copyWith(chatRooms: updatedRooms);
  }
}

/// 메시지 목록 상태
class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final bool isSending;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// 메시지 목록 Notifier
class MessagesNotifier extends StateNotifier<MessagesState> {
  final String chatRoomId;

  MessagesNotifier(this.chatRoomId) : super(const MessagesState());

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      messages: DemoDataService.getChatMessages(chatRoomId),
      isLoading: false,
    );
  }

  Future<void> sendReply(String content, {String? replyToId}) async {
    state = state.copyWith(isSending: true);

    await Future.delayed(const Duration(milliseconds: 500));

    final newMessage = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      chatRoomId: chatRoomId,
      content: content,
      type: MessageType.text,
      senderType: SenderType.fan,
      replyToId: replyToId,
      isRead: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
      isSending: false,
    );
  }
}

/// Providers
final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
  return ChatRoomsNotifier();
});

final messagesProvider = StateNotifierProvider.family<MessagesNotifier, MessagesState, String>(
  (ref, chatRoomId) => MessagesNotifier(chatRoomId),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(chatRoomsProvider).totalUnreadCount;
});
