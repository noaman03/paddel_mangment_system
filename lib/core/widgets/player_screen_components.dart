import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Shared building blocks for the player-facing screens (Courts, Matches,
/// Tournaments, Messages).
///
/// Everything here reads its colours from `context.padel` inside `build()` so
/// the widgets follow a live theme switch instead of freezing on whatever
/// brightness was current when they were first laid out.

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class PlayerScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final bool showNotifications;

  /// Optional extra action rendered to the left of the notification bell.
  final Widget? trailing;

  const PlayerScreenHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.showNotifications = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        ASizes.paddingMd,
        ASizes.paddingMd,
        ASizes.paddingMd,
        ASizes.paddingSm,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AColors.brandGradient,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AColors.primaryColor.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PlayerHeaderPatternPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // White-on-brand is intentional here: this surface is
                    // always the green gradient, in both themes.
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    _iconForTitle(title),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: ASizes.fontSizeLg + 3,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _subtitleForTitle(title),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ASizes.fontSizeSm,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
                if (showNotifications) ...[
                  const SizedBox(width: 8),
                  _NotificationBell(
                    count: notificationCount,
                    onTap: onNotificationTap,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitleForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'matches':
      case 'padel matches':
        return 'Find players and join competitive games';
      case 'courts':
      case 'find courts':
        return 'Book premium courts around you';
      case 'tournaments':
        return 'Compete, register, and track requests';
      case 'messages':
        return 'Stay close to players and court owners';
      default:
        return 'Your padel activity, all in one place';
    }
  }

  static IconData _iconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'matches':
      case 'padel matches':
        return Icons.sports_tennis;
      case 'courts':
      case 'find courts':
        return Icons.location_on;
      case 'tournaments':
        return Icons.emoji_events;
      case 'messages':
        return Icons.chat_bubble_outline;
      default:
        return Icons.sports;
    }
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Stack(
        children: [
          IconButton(
            tooltip: 'Notifications',
            // Never leave the bell as a dead control: screens that do not pass
            // a handler still explain what it would do.
            onPressed: onTap ??
                () => AppFeedback.info(
                      'Notifications',
                      count > 0
                          ? 'You have $count pending update(s).'
                          : 'You are all caught up — nothing new right now.',
                    ),
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AColors.error,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    // White on the error red is only 3.9:1 at this size.
                    color: AColors.foregroundOn(AColors.error),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerHeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var x = -size.height; x < size.width + size.height; x += 30) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }

    final courtPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final court = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.58, 10, size.width * 0.34, size.height - 20),
      const Radius.circular(16),
    );
    canvas.drawRRect(court, courtPaint);
    canvas.drawLine(
      Offset(size.width * 0.75, 12),
      Offset(size.width * 0.75, size.height - 12),
      courtPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.93, size.height * 0.28),
      10,
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

/// Search field shared by Courts, Matches, Tournaments and Messages.
///
/// This is stateful on purpose. The clear (X) affordance depends on the text
/// the user has typed, and typing into a [TextField] does not rebuild an
/// ancestor `StatelessWidget` — so as a StatelessWidget the X never appeared.
/// The suffix now listens to the controller directly.
class PlayerSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const PlayerSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  State<PlayerSearchBar> createState() => _PlayerSearchBarState();
}

class _PlayerSearchBarState extends State<PlayerSearchBar> {
  late TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant PlayerSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
    }
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final bool focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? AColors.primaryColor : c.border,
          width: focused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: focused
                ? AColors.primaryColor.withValues(alpha: 0.18)
                : c.shadow,
            blurRadius: focused ? 18 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: c.textPrimary,
          fontSize: ASizes.fontSizeMd,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          filled: false,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: c.textMuted,
            fontSize: ASizes.fontSizeMd,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            // brandText, not the raw accent: the vivid green is ~1.8:1 on the
            // white field in light mode. The focused *border* keeps the accent.
            color: focused ? c.brandText : c.textSecondary,
            size: 22,
          ),
          // ValueListenableBuilder keeps the clear button in sync with every
          // keystroke, including programmatic changes from the controller.
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear search',
                icon: Icon(Icons.close_rounded, color: c.textSecondary),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              );
            },
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ASizes.paddingMd,
            vertical: ASizes.paddingSm + 6,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab bar
// ---------------------------------------------------------------------------

class PlayerTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  /// Optional leading icon per tab. Extra/missing entries are ignored, so a
  /// short list never throws.
  final List<IconData>? icons;

  const PlayerTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          // The deep brand gradient, not the vivid accent: the old
          // primaryLight -> primaryDark ramp started at #29E68F, where the
          // white label sat at 1.64:1.
          gradient: const LinearGradient(colors: AColors.brandGradient),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: AColors.primaryColor.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStatePropertyAll<Color>(
          AColors.primaryColor.withValues(alpha: 0.08),
        ),
        // Derived from the gradient's lightest stop, so the whole indicator
        // clears AA.
        labelColor: AColors.foregroundOn(AColors.primaryDeep),
        unselectedLabelColor: c.textSecondary,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: ASizes.fontSizeSm,
          letterSpacing: 0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: ASizes.fontSizeSm,
          letterSpacing: 0,
        ),
        tabs: List<Widget>.generate(tabs.length, (index) {
          final IconData? icon =
              (icons != null && index < icons!.length) ? icons![index] : null;
          return Tab(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    tabs[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter button
// ---------------------------------------------------------------------------

/// A single filter chip/button.
///
/// It deliberately returns a plain [AnimatedContainer] and **not** an
/// `Expanded`: every call site already wraps it in its own `Expanded` inside a
/// `Row`, and `Expanded` inside `Expanded` throws "Incorrect use of
/// ParentDataWidget" and blanks the whole screen. Sizing belongs to the caller.
class PlayerFilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool hasActiveFilters;

  /// Optional number of active filters, shown as a badge instead of the dot.
  final int? count;

  const PlayerFilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.hasActiveFilters = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    // Foreground for the active (gradient-filled) state, derived from the
    // gradient's lightest stop rather than hardcoded to white.
    final Color onBrand = c.foregroundOn(AColors.primaryDeep);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: hasActiveFilters
            ? const LinearGradient(colors: AColors.brandGradient)
            : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: hasActiveFilters
            ? [
                BoxShadow(
                  color: AColors.primaryColor.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 5),
              if (count != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: onBrand.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: onBrand,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: onBrand,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ],
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: hasActiveFilters ? Colors.transparent : c.surface,
          foregroundColor: hasActiveFilters ? onBrand : c.textPrimary,
          side: BorderSide(
            color: hasActiveFilters ? Colors.transparent : c.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class PlayerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const PlayerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASizes.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                // Opaque tinted disc. The old code applied `.withOpacity(0.5)`
                // on top of a translucent token, which produced a bright
                // near-white circle on the dark scaffold.
                color: c.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AColors.primaryColor.withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                icon,
                size: 56,
                color: c.onSurfaceAccent(AColors.primaryColor),
              ),
            ),
            const SizedBox(height: ASizes.spaceBtwItems + 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: ASizes.spaceBtwItems / 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            if (action != null) ...[
              const SizedBox(height: ASizes.spaceBtwSections),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

class PlayerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;

  const PlayerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final Color resolvedBorder =
        showBorder ? (borderColor ?? AColors.primaryColor) : c.border;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(
          color: resolvedBorder,
          width: showBorder ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
          splashColor: AColors.primaryColor.withValues(alpha: 0.10),
          highlightColor: AColors.primaryColor.withValues(alpha: 0.05),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(ASizes.paddingMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

/// Small coloured status pill (OPEN / FULL / OFFICIAL / skill level / …).
///
/// The label colour is derived from the fill instead of being hardcoded to
/// white: white on the brand green (#1DD681) or on amber sits around 2-3:1 and
/// read as an unlabelled smear.
class PlayerStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  /// When true the pill is drawn as a soft tinted chip instead of a solid
  /// fill — useful when several badges sit next to each other on a card.
  final bool soft;

  const PlayerStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    final Color background = soft ? c.soft(color) : color;
    // Solid pill: pick whichever of white/ink actually contrasts with the fill.
    // `estimateBrightnessForColor` only thresholds at 0.15 luminance, so it
    // still returned white for mid-tone fills such as the error red (3.9:1).
    final Color foreground =
        soft ? c.onSurfaceAccent(color) : c.foregroundOn(color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: soft ? Border.all(color: color.withValues(alpha: 0.35)) : null,
        boxShadow: soft
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
