import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padelsystem/core/const/colors.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<ChatConversationUI> _conversations;
  late List<ChatConversationUI> _filteredConversations;

  @override
  void initState() {
    super.initState();
    _conversations = _getDummyConversations();
    _filteredConversations = _conversations;
  }

  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchChats,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon:
                    const Icon(Icons.search, color: AColors.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _searchChats('');
                        },
                        child: const Icon(Icons.close),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Chat List
          Expanded(
            child: _filteredConversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations found',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _filteredConversations[index];
                      return _buildChatTile(context, conversation, dark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(
      BuildContext context, ChatConversationUI conversation, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AColors.primaryColor.withOpacity(0.2),
          child: Text(
            conversation.participantName[0].toUpperCase(),
            style: const TextStyle(
              color: AColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          conversation.participantName,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.lastMessageTime),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            if (conversation.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(conversation: conversation),
            ),
          );
        },
      ),
    );
  }

  void _searchChats(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations
            .where((conv) =>
                conv.participantName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                conv.lastMessage.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${messageDate.day}/${messageDate.month}';
    }
  }

  List<ChatConversationUI> _getDummyConversations() {
    return [
      ChatConversationUI(
        id: '1',
        participantName: 'Ahmed Hassan',
        lastMessage: 'Hey! Are you free tomorrow for a game?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      ChatConversationUI(
        id: '2',
        participantName: 'Sara Mohamed',
        lastMessage: 'The court was amazing! Want to play again next week?',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
      ChatConversationUI(
        id: '3',
        participantName: 'Al Noor Club Owner',
        lastMessage: 'Your booking confirmed for tomorrow at 5 PM',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
      ),
      ChatConversationUI(
        id: '4',
        participantName: 'Fatima Ali',
        lastMessage: 'Let\'s organize a team for the spring tournament!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
        unreadCount: 0,
      ),
      ChatConversationUI(
        id: '5',
        participantName: 'Ali Karim',
        lastMessage: 'Thanks for the great match today buddy!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
        unreadCount: 0,
      ),
      ChatConversationUI(
        id: '6',
        participantName: 'Rainom Abdulrahman',
        lastMessage: 'شنو تاني يوم فراغك؟ بننظم مباراة',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 4)),
        unreadCount: 0,
      ),
      ChatConversationUI(
        id: '7',
        participantName: 'Hanem Azima',
        lastMessage: 'What\'s the registration fee for the summer tournament?',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 5)),
        unreadCount: 0,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ChatDetailScreen extends StatefulWidget {
  final ChatConversationUI conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late TextEditingController _messageController;
  late List<ChatMessageUI> _messages;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messages = _getDummyMessages();
  }

  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.participantName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isCurrentUser = message.senderId == 'current_user';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? AColors.primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: isCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color:
                                  isCurrentUser ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMessageTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrentUser
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? Colors.grey[900] : Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.add_a_photo,
                      color: AColors.primaryColor),
                  onPressed: () {},
                ),
                // Message input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: dark ? Colors.grey[800] : Colors.grey[100],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.insert(
          0,
          ChatMessageUI(
            id: DateTime.now().toString(),
            senderId: 'current_user',
            content: _messageController.text,
            timestamp: DateTime.now(),
          ),
        );
        _messageController.clear();
      });
    }
  }

  String _formatMessageTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  List<ChatMessageUI> _getDummyMessages() {
    return [
      ChatMessageUI(
        id: '1',
        senderId: widget.conversation.id,
        content: 'Hey! Are you free tomorrow? I can play after 5 PM',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessageUI(
        id: '2',
        senderId: 'current_user',
        content: 'Yeah! 5 PM works perfectly for me',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessageUI(
        id: '3',
        senderId: widget.conversation.id,
        content: 'Which court should we use - Al Ahmar or Al Noor?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessageUI(
        id: '4',
        senderId: 'current_user',
        content:
            'Let\'s do Al Ahmar! They have great facilities and a restaurant there',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ChatMessageUI(
        id: '5',
        senderId: widget.conversation.id,
        content: 'Perfect! I\'ll book it now and see you tomorrow 🎾',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// UI Models
class ChatConversationUI {
  final String id;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatConversationUI({
    required this.id,
    required this.participantName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

class ChatMessageUI {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;

  ChatMessageUI({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}
