import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:padel_management_system/Features/owner/data/owner_models.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

/// Shared chrome for the owner panel, so the owner screens read as the same
/// product as the player screens (same radius, same palette, same feedback).

/// Card surface used by every owner list item. Mirrors `PlayerCard`.
class OwnerCard extends StatelessWidget {
  const OwnerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final radius = BorderRadius.circular(ASizes.cardRadiusLg);

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
        border: Border.all(color: accent ?? c.border),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Section title with an optional trailing action, used on the dashboard.
class OwnerSectionHeader extends StatelessWidget {
  const OwnerSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Padding(
      padding: const EdgeInsets.only(bottom: ASizes.sm + 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Small pill used for statuses across the owner panel.
class OwnerStatusPill extends StatelessWidget {
  const OwnerStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    // Filled: the pill *is* the status colour, so ask which of white/ink reads
    // on it — white is only 2.04:1 on the warning amber.
    final Color foreground =
        filled ? c.foregroundOn(color) : c.onSurfaceAccent(color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : c.soft(color),
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + label + value line used inside the tournament and booking cards.
class OwnerDetailRow extends StatelessWidget {
  const OwnerDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: c.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: c.textMuted,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Renders a court photo whether it is a seeded remote URL or a file the owner
/// just picked from the gallery. The upload flow used to throw the picked file
/// away and re-add the same stock URL every time.
class CourtImageView extends StatelessWidget {
  const CourtImageView({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
  });

  final String source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (isRemoteImage(source)) {
      return Image.network(
        source,
        fit: fit,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const CourtImagePlaceholder(),
        errorBuilder: (_, __, ___) => const CourtImagePlaceholder(),
      );
    }
    // `XFile.path` is a blob URL on web and a real file path everywhere else.
    if (kIsWeb) {
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (_, __, ___) => const CourtImagePlaceholder(),
      );
    }
    return Image.file(
      File(source),
      fit: fit,
      errorBuilder: (_, __, ___) => const CourtImagePlaceholder(),
    );
  }
}

/// Brand-coloured stand-in shown while a photo loads or when it cannot load —
/// this demo runs offline, so that is the common case.
class CourtImagePlaceholder extends StatelessWidget {
  const CourtImagePlaceholder({super.key, this.iconSize = ASizes.iconLg});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // The deep brand gradient, not the vivid green: the "Add court
          // photos" call to action is painted white on top of this.
          colors: AColors.brandGradient,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.sports_tennis_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

/// Bottom-to-top scrim so white overlay text stays readable on any photo.
class CourtImageScrim extends StatelessWidget {
  const CourtImageScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.06),
            Colors.black.withValues(alpha: 0.36),
          ],
        ),
      ),
    );
  }
}

/// Compact action button for the card action rows.
///
/// The app-wide `ElevatedButton` theme forces 16sp / 16px vertical padding,
/// which made three buttons in one card row wrap or clip. These override it.
class OwnerActionButton extends StatelessWidget {
  const OwnerActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tone,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? tone;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final Color color = tone ?? AColors.primaryColor;
    const textStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);

    if (filled) {
      // The accent green is too light to carry a label, so an untoned filled
      // button uses the deep brand fill; a toned one keeps its status colour
      // and takes whichever foreground reads on it.
      final Color fill = tone ?? AColors.primaryDeep;
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          backgroundColor: fill,
          foregroundColor: c.foregroundOn(fill),
          textStyle: textStyle,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ASizes.buttonRadius),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: c.onSurfaceAccent(color),
        textStyle: textStyle,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        side: BorderSide(color: color.withValues(alpha: 0.45)),
        backgroundColor: c.soft(color).withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ASizes.buttonRadius),
        ),
      ),
    );
  }
}

/// Empty state shared by the courts and tournaments tabs.
class OwnerEmptyState extends StatelessWidget {
  const OwnerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: c.textMuted),
            ),
            const SizedBox(height: ASizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: c.textSecondary, height: 1.4),
            ),
            if (action != null) ...[
              const SizedBox(height: ASizes.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
