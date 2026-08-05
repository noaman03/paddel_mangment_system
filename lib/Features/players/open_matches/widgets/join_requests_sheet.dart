import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_colors.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_pieces.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// The join-requests inbox behind the header bell.
///
/// This sheet used to be unreachable: the screen shadowed `showNotifications`
/// with an empty local method, so the badge showed "2" and tapping it did
/// nothing.
Future<void> showJoinRequestsSheet(BuildContext context) {
  final controller = Get.find<OpenMatchesController>();

  return showAppSheet<void>(
    context,
    title: 'Join Requests',
    subtitle: 'Players asking to join the matches you host',
    icon: Icons.mark_email_unread_rounded,
    heightFactor: 0.8,
    // NOTE: the "Clear all" action must live inside its own Obx — the sheet
    // header is built once, so without this it lingered above an empty list.
    actions: [
      Obx(() {
        if (controller.joinRequests.isEmpty) return const SizedBox.shrink();
        return TextButton(
          onPressed: () async {
            final ok = await AppFeedback.confirm(
              context,
              title: 'Clear all requests?',
              message:
                  'All ${controller.joinRequests.length} pending requests will '
                  'be dismissed without joining anyone.',
              confirmLabel: 'Clear all',
              icon: Icons.clear_all_rounded,
              destructive: true,
            );
            if (ok) controller.clearJoinRequests();
          },
          child: Text(
            'Clear all',
            style: TextStyle(
              // The accent green is unreadable as text on a light sheet.
              color: context.padel.brandText,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }),
    ],
    child: Obx(() {
      if (controller.joinRequests.isEmpty) {
        return const _NoRequests();
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: controller.joinRequests.length,
        itemBuilder: (_, index) => _JoinRequestTile(
          request: controller.joinRequests[index],
        ),
      );
    }),
  );
}

class _NoRequests extends StatelessWidget {
  const _NoRequests();

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASizes.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: ASizes.spaceBtwItems),
            Text(
              'You are all caught up',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'New join requests for your matches will appear here.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinRequestTile extends StatelessWidget {
  const _JoinRequestTile({required this.request});

  final Map<String, dynamic> request;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final controller = Get.find<OpenMatchesController>();
    final String skill = request['skillLevel'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: c.fill,
                backgroundImage: AssetImage(request['playerAvatar'] as String),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['playerName'] as String,
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'wants to join "${request['matchTitle']}"',
                      style: text.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MatchBadge(label: skill, color: getSkillLevelColor(skill)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${request['message']}"',
            style: text.bodySmall?.copyWith(
              color: c.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 13, color: c.textMuted),
              const SizedBox(width: 4),
              Text(
                formatTimestamp(request['timestamp'] as DateTime),
                style: text.bodySmall?.copyWith(color: c.textMuted),
              ),
              const Spacer(),
              _ActionChip(
                icon: Icons.close_rounded,
                tone: AColors.error,
                tooltip: 'Decline request',
                onTap: () =>
                    controller.rejectJoinRequest(request['id'] as String),
              ),
              const SizedBox(width: 8),
              _ActionChip(
                icon: Icons.check_rounded,
                tone: AColors.success,
                tooltip: 'Accept request',
                filled: true,
                onTap: () =>
                    controller.acceptJoinRequest(request['id'] as String),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.tone,
    required this.tooltip,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final Color tone;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? tone : c.soft(tone),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tone.withValues(alpha: 0.4)),
            ),
            child: Icon(
              icon,
              size: 19,
              // Filled: the chip *is* the status colour, so ask which
              // foreground survives on it — white is only 3.0:1 on the success
              // green. Unfilled: it is a tint of the surface instead.
              color:
                  filled ? AColors.foregroundOn(tone) : c.onSurfaceAccent(tone),
            ),
          ),
        ),
      ),
    );
  }
}
