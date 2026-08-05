/// Id used for the signed-in player in the offline chat demo.
const String kCurrentUserId = 'current_user';

/// One message in a conversation.
///
/// `chat_screen.dart` used to declare near-duplicate `ChatMessageUI` /
/// `ChatConversationUI` classes; those are gone and the screen now renders
/// these models directly.
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  bool get isMine => senderId == kCurrentUserId;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      conversationId: map['conversationId']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? 'User',
      content: map['content']?.toString() ?? '',
      timestamp: parseChatTimestamp(map['timestamp']),
      isRead: map['isRead'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}

/// A one-to-one conversation shown in the Messages tab.
class ChatConversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isMuted;

  const ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantRole = 'Player',
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
  });

  String get initial => participantName.trim().isEmpty
      ? '?'
      : participantName.trim()[0].toUpperCase();

  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantRole,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isMuted,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantRole: participantRole ?? this.participantRole,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map, String docId) {
    return ChatConversation(
      id: docId,
      participantId: map['participantId']?.toString() ?? '',
      participantName: map['participantName']?.toString() ?? 'User',
      participantRole: map['participantRole']?.toString() ?? 'Player',
      lastMessage: map['lastMessage']?.toString() ?? '',
      lastMessageTime: parseChatTimestamp(map['lastMessageTime']),
      unreadCount: (map['unreadCount'] as num?)?.toInt() ?? 0,
      isMuted: map['isMuted'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'participantRole': participantRole,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isMuted': isMuted,
    };
  }
}

/// Accepts ISO strings, `DateTime`s and Firestore `Timestamp`s (which only
/// expose `toDate()`), so a round-tripped document cannot crash the chat list.
DateTime parseChatTimestamp(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value != null) {
    try {
      // ignore: avoid_dynamic_calls
      final converted = value.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {
      // Not a Timestamp-like object.
    }
  }
  return DateTime.now();
}
