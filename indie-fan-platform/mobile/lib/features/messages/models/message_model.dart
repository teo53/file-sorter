enum MessageType { text, image, video, audio, sticker }
enum SenderType { artist, fan, system }

class Message {
  final String id;
  final String chatRoomId;
  final String content;
  final MessageType type;
  final SenderType senderType;
  final String? mediaUrl;
  final String? replyToId;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.content,
    required this.type,
    required this.senderType,
    this.mediaUrl,
    this.replyToId,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatRoomId: json['chatRoomId'] as String,
      content: json['content'] as String,
      type: _parseType(json['type'] as String),
      senderType: _parseSenderType(json['senderType'] as String),
      mediaUrl: json['mediaUrl'] as String?,
      replyToId: json['replyToId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static MessageType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'IMAGE':
        return MessageType.image;
      case 'VIDEO':
        return MessageType.video;
      case 'AUDIO':
        return MessageType.audio;
      case 'STICKER':
        return MessageType.sticker;
      default:
        return MessageType.text;
    }
  }

  static SenderType _parseSenderType(String type) {
    switch (type.toUpperCase()) {
      case 'FAN':
        return SenderType.fan;
      case 'SYSTEM':
        return SenderType.system;
      default:
        return SenderType.artist;
    }
  }

  bool get isFromArtist => senderType == SenderType.artist;
  bool get isFromFan => senderType == SenderType.fan;
}

class ChatRoom {
  final String id;
  final String artistId;
  final String artistName;
  final String artistImage;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final int replyCount;
  final int maxReplies;

  ChatRoom({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.artistImage,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.replyCount = 0,
    this.maxReplies = 3,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      artistId: json['artistId'] as String,
      artistName: json['artistName'] as String,
      artistImage: json['artistImage'] as String,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      maxReplies: json['maxReplies'] as int? ?? 3,
    );
  }

  bool get canReply => replyCount < maxReplies;
  int get remainingReplies => maxReplies - replyCount;
}
