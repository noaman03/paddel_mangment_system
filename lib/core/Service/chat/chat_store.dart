import 'package:get/get.dart';
import 'package:padel_management_system/Models/chat_message.dart';

/// In-memory chat repository for the offline demo.
///
/// The Messages tab used to keep its dummy data inside the widget state, so a
/// sent message vanished as soon as you left the conversation and the unread
/// badge never cleared. Both screens now read this store, so sending, muting
/// and clearing a chat have consequences that survive navigation.
class ChatStore extends GetxController {
  /// Registered lazily so no screen depends on main.dart wiring it up.
  static ChatStore get to => Get.isRegistered<ChatStore>()
      ? Get.find<ChatStore>()
      : Get.put(ChatStore(), permanent: true);

  ChatStore() {
    conversations.assignAll(_seedConversations());
    for (final conversation in conversations) {
      _threads[conversation.id] = _seedThread(conversation).obs;
    }
  }

  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;
  final Map<String, RxList<ChatMessage>> _threads = {};

  int get totalUnread => conversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// The message list for a conversation. Reading `.value`-backed members of
  /// the returned list inside an `Obx` keeps the thread live.
  RxList<ChatMessage> thread(String conversationId) =>
      _threads.putIfAbsent(conversationId, () => <ChatMessage>[].obs);

  ChatConversation? byId(String conversationId) {
    for (final conversation in conversations) {
      if (conversation.id == conversationId) return conversation;
    }
    return null;
  }

  void _update(String conversationId,
      ChatConversation Function(ChatConversation) transform) {
    final index = conversations.indexWhere((c) => c.id == conversationId);
    if (index < 0) return;
    conversations[index] = transform(conversations[index]);
  }

  void markRead(String conversationId) {
    _update(conversationId,
        (c) => c.unreadCount == 0 ? c : c.copyWith(unreadCount: 0));
  }

  bool toggleMute(String conversationId) {
    final conversation = byId(conversationId);
    if (conversation == null) return false;
    final muted = !conversation.isMuted;
    _update(conversationId, (c) => c.copyWith(isMuted: muted));
    return muted;
  }

  void clearThread(String conversationId) {
    thread(conversationId).clear();
    _update(
      conversationId,
      (c) => c.copyWith(lastMessage: 'No messages yet', unreadCount: 0),
    );
  }

  /// Appends a message from the signed-in player and bumps the conversation to
  /// the top of the list. [autoReply] fakes the other side answering so the
  /// demo conversation moves.
  void send(String conversationId, String content, {bool autoReply = true}) {
    final text = content.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();

    thread(conversationId).add(
      ChatMessage(
        id: 'm-${now.microsecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: kCurrentUserId,
        senderName: 'You',
        content: text,
        timestamp: now,
        isRead: true,
      ),
    );
    _touch(conversationId, 'You: $text', now);

    if (!autoReply) return;
    Future.delayed(const Duration(milliseconds: 1400), () {
      final conversation = byId(conversationId);
      if (conversation == null) return;
      final reply = _replies[thread(conversationId).length % _replies.length];
      final replyTime = DateTime.now();
      thread(conversationId).add(
        ChatMessage(
          id: 'm-${replyTime.microsecondsSinceEpoch}',
          conversationId: conversationId,
          senderId: conversation.participantId,
          senderName: conversation.participantName,
          content: reply,
          timestamp: replyTime,
        ),
      );
      _touch(conversationId, reply, replyTime);
    });
  }

  void _touch(String conversationId, String lastMessage, DateTime when) {
    final index = conversations.indexWhere((c) => c.id == conversationId);
    if (index < 0) return;
    final updated = conversations[index]
        .copyWith(lastMessage: lastMessage, lastMessageTime: when);
    conversations
      ..removeAt(index)
      ..insert(0, updated);
  }

  static const List<String> _replies = [
    'Sounds good — see you on court!',
    'Perfect, I will book the slot now.',
    'Let me check with the club and get back to you.',
    'Great match today, same time next week?',
    'I can bring an extra racket if you need one.',
  ];

  List<ChatConversation> _seedConversations() {
    final now = DateTime.now();
    return [
      ChatConversation(
        id: 'c1',
        participantId: 'p-ahmed',
        participantName: 'Ahmed Hassan',
        participantRole: 'Player · 4.2 level',
        lastMessage: 'Hey! Are you free tomorrow for a game?',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      ChatConversation(
        id: 'c2',
        participantId: 'p-sara',
        participantName: 'Sara Mohamed',
        participantRole: 'Player · 3.8 level',
        lastMessage: 'The court was amazing! Want to play again next week?',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
      ),
      ChatConversation(
        id: 'c3',
        participantId: 'o-alnoor',
        participantName: 'Al Noor Club',
        participantRole: 'Club owner · Downtown Cairo',
        lastMessage: 'Your booking is confirmed for tomorrow at 5 PM.',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 1,
      ),
      ChatConversation(
        id: 'c4',
        participantId: 'p-fatima',
        participantName: 'Fatima Ali',
        participantRole: 'Player · 4.0 level',
        lastMessage: 'Let\'s organize a team for the spring tournament!',
        lastMessageTime: now.subtract(const Duration(days: 2)),
      ),
      ChatConversation(
        id: 'c5',
        participantId: 'p-ali',
        participantName: 'Ali Karim',
        participantRole: 'Player · 3.5 level',
        lastMessage: 'Thanks for the great match today!',
        lastMessageTime: now.subtract(const Duration(days: 3)),
      ),
      ChatConversation(
        id: 'c6',
        participantId: 'p-rainom',
        participantName: 'Rainom Abdulrahman',
        participantRole: 'Player · 4.5 level',
        lastMessage: 'Are you free later this week? We are organizing a match.',
        lastMessageTime: now.subtract(const Duration(days: 4)),
      ),
      ChatConversation(
        id: 'c7',
        participantId: 'p-hanem',
        participantName: 'Hanem Azima',
        participantRole: 'Tournament desk',
        lastMessage: 'What\'s the registration fee for the summer tournament?',
        lastMessageTime: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<ChatMessage> _seedThread(ChatConversation conversation) {
    final base = conversation.lastMessageTime;
    ChatMessage from(int index, bool mine, String content, int minutesBefore) {
      return ChatMessage(
        id: '${conversation.id}-m$index',
        conversationId: conversation.id,
        senderId: mine ? kCurrentUserId : conversation.participantId,
        senderName: mine ? 'You' : conversation.participantName,
        content: content,
        timestamp: base.subtract(Duration(minutes: minutesBefore)),
        isRead: true,
      );
    }

    return [
      from(1, false, 'Hey! Are you free tomorrow? I can play after 5 PM.', 12),
      from(2, true, 'Yes, 5 PM works perfectly for me.', 10),
      from(3, false, 'Which court should we use — Al Ahmar or Al Noor?', 8),
      from(
        4,
        true,
        'Let\'s do Al Ahmar, they have great facilities and a restaurant.',
        5,
      ),
      from(5, false, conversation.lastMessage, 0),
    ];
  }
}
