import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

/// Small tinted pill used for skill level, match type and request counts.
///
/// Uses `soft()` / `onSurfaceAccent()` so the label stays legible on both the
/// light and the dark card surface without hardcoding white text.
class MatchBadge extends StatelessWidget {
  const MatchBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.soft(color),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c.onSurfaceAccent(color)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: c.onSurfaceAccent(color),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + text metadata line (location, time, duration...).
class MatchMetaRow extends StatelessWidget {
  const MatchMetaRow({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Row(
      children: [
        Icon(icon, size: ASizes.iconSm, color: c.brandText),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Joined-player avatars followed by one placeholder per free slot.
class MatchPlayersStrip extends StatelessWidget {
  const MatchPlayersStrip({
    super.key,
    required this.match,
    this.radius = 12,
  });

  final Map<String, dynamic> match;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final List players = match['players'] as List? ?? const [];
    final int free = (match['playersNeeded'] as int? ?? 0).clamp(0, 8);

    // A Row (not a Wrap) so the strip keeps its intrinsic width when it sits
    // next to a Spacer — a Wrap would be squeezed and break onto extra lines.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final player in players)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: c.surfaceElevated,
              backgroundImage: AssetImage(player['avatar'] as String),
            ),
          ),
        for (int i = 0; i < free; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: c.fill,
              child: Icon(
                Icons.add_rounded,
                size: radius * 1.2,
                // The old code painted this white on a near-white circle, so
                // the "+" was invisible in both themes.
                color: c.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

/// The primary call to action for a match.
///
/// Reads `joinedMatchIds` inside its own [Obx]: an ancestor Obx would not
/// track a `.value` read that happens in this widget's own build().
class MatchJoinButton extends StatelessWidget {
  const MatchJoinButton({
    super.key,
    required this.match,
    this.expanded = true,
    this.onJoinPressed,
  });

  final Map<String, dynamic> match;
  final bool expanded;

  /// Replaces the default "join right now" behaviour.
  ///
  /// A surface that disappears on join — a modal sheet — passes this so it can
  /// close *first* and join afterwards: the sheet owns the ScaffoldMessenger
  /// the controller's confirmation would land on, so a toast raised on the way
  /// out is torn down with it.
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final controller = Get.find<OpenMatchesController>();
    final String matchId = match['id'] as String;

    return Obx(() {
      final bool joined = controller.joinedMatchIds.contains(matchId);
      final bool full = (match['playersNeeded'] as int? ?? 0) <= 0;

      final String label = joined
          ? 'Requested'
          : full
              ? 'Full'
              : 'Join Match';
      final IconData icon = joined
          ? Icons.check_circle_rounded
          : full
              ? Icons.lock_outline_rounded
              : Icons.sports_tennis_rounded;

      final button = ElevatedButton.icon(
        onPressed: (joined || full)
            ? null
            : (onJoinPressed ?? () => controller.joinMatch(matchId)),
        icon: Icon(icon, size: 18),
        style: ElevatedButton.styleFrom(
          // primaryDeep, not the vivid accent: white on #1DD681 is 1.91:1.
          backgroundColor: AColors.primaryDeep,
          foregroundColor: AColors.foregroundOn(AColors.primaryDeep),
          disabledBackgroundColor: c.fill,
          disabledForegroundColor: c.textMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
          ),
        ),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );

      return expanded
          ? SizedBox(width: double.infinity, child: button)
          : button;
    });
  }
}
