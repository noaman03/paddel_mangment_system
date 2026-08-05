import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Models/chat_message.dart';
import 'package:padel_management_system/core/Service/chat/chat_store.dart';
import 'package:padel_management_system/core/Service/reservations/reservation_store.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/utils/formatters/formatter.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatStore _store = ChatStore.to;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No background override: the theme's scaffold colour keeps this tab
      // consistent with every other tab in the bottom bar.
      body: SafeArea(
        child: Column(
          children: [
            const PlayerScreenHeader(
              title: 'Messages',
              showNotifications: false,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ASizes.paddingMd),
                child: Column(
                  children: [
                    PlayerSearchBar(
                      controller: _searchController,
                      hintText: 'Search chats, players, or clubs...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: ASizes.spaceBtwItems),
                    Expanded(
                      child: Obx(() {
                        final conversations = _filter(_store.conversations);
                        if (conversations.isEmpty) {
                          return PlayerEmptyState(
                            icon: Icons.message_outlined,
                            title: _query.isEmpty
                                ? 'No conversations yet'
                                : 'No conversations found',
                            subtitle: _query.isEmpty
                                ? 'Message a club or a player to get a game going.'
                                : 'Try another name or start a new padel chat.',
                          );
                        }
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: conversations.length,
                          itemBuilder: (context, index) =>
                              _ChatTile(conversation: conversations[index]),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChatConversation> _filter(List<ChatConversation> source) {
    if (_query.trim().isEmpty) return source.toList();
    final query = _query.toLowerCase();
    return source
        .where((c) =>
            c.participantName.toLowerCase().contains(query) ||
            c.lastMessage.toLowerCase().contains(query))
        .toList();
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.conversation});

  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: c.primarySoft,
          child: Text(
            conversation.initial,
            // The plain brand green was almost invisible on its own tint.
            style: text.titleMedium?.copyWith(
              color: c.onSurfaceAccent(AColors.primaryDark),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                conversation.participantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (conversation.isMuted) ...[
              const SizedBox(width: 6),
              Icon(Icons.notifications_off_rounded,
                  size: 14, color: c.textMuted),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.lastMessageTime),
              style: text.bodySmall?.copyWith(color: c.textMuted),
            ),
            if (conversation.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  // Dark text on the light brand green reads far better than
                  // white did (~11:1 instead of ~1.9:1).
                  style: const TextStyle(
                    color: AColors.textprimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(conversationId: conversation.id),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    }
    if (messageDate == yesterday) return 'Yesterday';
    return '${messageDate.day}/${messageDate.month}';
  }
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatStore _store = ChatStore.to;

  @override
  void initState() {
    super.initState();
    // Mutating the store synchronously here would rebuild an Obx while this
    // route is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.markRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() {
          final conversation = _store.byId(widget.conversationId);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                conversation?.participantName ?? 'Conversation',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (conversation != null)
                Text(
                  conversation.participantRole,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.textSecondary),
                ),
            ],
          );
        }),
        actions: [
          IconButton(
            tooltip: 'Voice call',
            icon: const Icon(Icons.call),
            onPressed: () => AppFeedback.info(
              'Voice calling is not in this demo',
              'The offline build ships messaging only.',
            ),
          ),
          Obx(() {
            final muted = _store.byId(widget.conversationId)?.isMuted ?? false;
            return PopupMenuButton<String>(
              tooltip: 'Conversation options',
              onSelected: (value) => _onMenuSelected(value, muted),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      Icon(
                        muted
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(muted ? 'Unmute' : 'Mute notifications'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Clear chat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Report player'),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = _store.thread(widget.conversationId).toList();
              if (messages.isEmpty) {
                return PlayerEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No messages',
                  subtitle:
                      'Say hello to ${_store.byId(widget.conversationId)?.participantName ?? 'your partner'} to start the conversation.',
                );
              }
              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  // reverse:true renders index 0 at the bottom, so walk the
                  // list backwards to keep the newest message there.
                  final message = messages[messages.length - 1 - index];
                  return _MessageBubble(message: message);
                },
              );
            }),
          ),
          _buildComposer(context),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Share something',
              icon: const Icon(Icons.add_circle_outline,
                  color: AColors.primaryColor),
              onPressed: _openAttachSheet,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: c.textMuted),
                  filled: true,
                  fillColor: c.fill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: _composerBorder,
                  enabledBorder: _composerBorder,
                  focusedBorder: _composerBorder.copyWith(
                    borderSide: const BorderSide(
                      color: AColors.primaryColor,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty;
                return Material(
                  color: canSend ? AColors.primaryDark : c.surfaceElevated,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: canSend ? _sendMessage : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: canSend ? Colors.white : c.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static final OutlineInputBorder _composerBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide.none,
  );

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _store.send(widget.conversationId, text);
    _messageController.clear();
    _scrollToNewest();
  }

  void _scrollToNewest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      // reverse:true — offset 0 is the newest message.
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onMenuSelected(String value, bool muted) async {
    switch (value) {
      case 'mute':
        final nowMuted = _store.toggleMute(widget.conversationId);
        if (nowMuted) {
          AppFeedback.info('Conversation muted', 'You will not be notified.');
        } else {
          AppFeedback.success('Conversation unmuted');
        }
        break;
      case 'clear':
        final ok = await AppFeedback.confirm(
          context,
          title: 'Clear this chat?',
          message: 'All messages in this conversation will be removed.',
          confirmLabel: 'Clear',
          icon: Icons.delete_sweep_outlined,
          destructive: true,
        );
        if (!ok) return;
        _store.clearThread(widget.conversationId);
        AppFeedback.success('Chat cleared');
        break;
      case 'report':
        AppFeedback.info(
          'Report submitted',
          'Our moderation team reviews reports within 24 hours.',
        );
        break;
    }
  }

  void _openAttachSheet() {
    final upcoming = ReservationStore.to.upcoming;
    final court = ReservationStore.catalogue.first;

    showAppSheet<void>(
      context,
      title: 'Share',
      subtitle: 'Send booking details straight into the chat',
      icon: Icons.attach_file_rounded,
      heightFactor: 0.45,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ASizes.paddingMd,
          vertical: ASizes.paddingSm,
        ),
        children: [
          _AttachOption(
            icon: Icons.event_available_rounded,
            title: 'My next reservation',
            subtitle: upcoming.isEmpty
                ? 'You have no upcoming reservations'
                : '${upcoming.first.courtName} · ${AFormatter.formatDayMonth(upcoming.first.bookingDate)}',
            enabled: upcoming.isNotEmpty,
            onTap: () {
              final booking = upcoming.first;
              Navigator.pop(context);
              _store.send(
                widget.conversationId,
                'I booked ${booking.courtName} (${booking.courtLocation}) on '
                '${AFormatter.formatDayMonth(booking.bookingDate)} at '
                '${booking.timeRangeLabel}. Join me?',
              );
              _scrollToNewest();
            },
          ),
          const SizedBox(height: ASizes.sm),
          _AttachOption(
            icon: Icons.stadium_outlined,
            title: 'Suggest a court',
            subtitle:
                '${court.name} · ${AFormatter.formatCurrency(court.pricePerHour)}/hour',
            onTap: () {
              Navigator.pop(context);
              _store.send(
                widget.conversationId,
                'How about ${court.name} in ${court.location}? '
                'It is ${AFormatter.formatCurrency(court.pricePerHour)} per hour.',
              );
              _scrollToNewest();
            },
          ),
          const SizedBox(height: ASizes.sm),
          _AttachOption(
            icon: Icons.photo_camera_outlined,
            title: 'Photo',
            subtitle: 'Not available in the offline demo',
            enabled: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
          onTap: enabled
              ? onTap
              : () => AppFeedback.info(
                    'Not available offline',
                    'Photo sharing needs a backend, which this demo does not use.',
                  ),
          child: Padding(
            padding: const EdgeInsets.all(ASizes.paddingMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AColors.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final isMine = message.isMine;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            // A darker green keeps the white bubble text readable; incoming
            // bubbles follow the palette so they are not a grey slab at night.
            color: isMine ? AColors.primaryDark : c.surfaceElevated,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
            border: isMine ? null : Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isMine ? Colors.white : c.textPrimary,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour.toString().padLeft(2, '0')}:'
                '${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: isMine
                      ? Colors.white.withValues(alpha: 0.8)
                      : c.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
