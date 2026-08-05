import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// App-wide user feedback (toasts, confirmations, sheets).
///
/// Why this exists: the app previously used `Get.snackbar` everywhere. On
/// Flutter 3.44 that throws `No Overlay widget found` in this setup, so every
/// action whose only feedback was a snackbar — "Join Tournament", "Join Match",
/// accept/reject request — silently did nothing from the user's point of view.
///
/// [AppFeedback] instead drives a [ScaffoldMessenger] through a global key
/// installed on the root app, which works from controllers, bottom sheets and
/// dialogs alike.
class AppFeedback {
  AppFeedback._();

  /// Installed on `GetMaterialApp(scaffoldMessengerKey: ...)` in `main.dart`.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Messengers belonging to modal surfaces currently on screen, innermost
  /// last. A modal bottom sheet covers the bottom of the app, so a snackbar
  /// posted to the root messenger would render *behind* it; [showAppSheet]
  /// registers its own messenger here so feedback raised from inside a sheet
  /// stays visible.
  static final List<GlobalKey<ScaffoldMessengerState>> _modalMessengers = [];

  static void pushMessenger(GlobalKey<ScaffoldMessengerState> key) =>
      _modalMessengers.add(key);

  static void popMessenger(GlobalKey<ScaffoldMessengerState> key) =>
      _modalMessengers.remove(key);

  static ScaffoldMessengerState? get _messenger {
    for (final key in _modalMessengers.reversed) {
      final state = key.currentState;
      if (state != null) return state;
    }
    final state = messengerKey.currentState;
    if (state != null) return state;
    final context = Get.context;
    if (context == null) return null;
    return ScaffoldMessenger.maybeOf(context);
  }

  static void success(String title, [String? message]) =>
      _show(title, message, AColors.success, Icons.check_circle_rounded);

  static void error(String title, [String? message]) =>
      _show(title, message, AColors.error, Icons.error_rounded);

  static void warning(String title, [String? message]) =>
      _show(title, message, AColors.warning, Icons.warning_amber_rounded);

  static void info(String title, [String? message]) =>
      _show(title, message, AColors.info, Icons.info_rounded);

  static void _show(
    String title,
    String? message,
    Color accent,
    IconData icon, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = _messenger;
    if (messenger == null) {
      debugPrint('[AppFeedback] $title${message == null ? '' : ' — $message'}');
      return;
    }

    final BuildContext? context = messengerKey.currentContext ?? Get.context;
    final bool isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;
    final Color background =
        isDark ? AColors.containerDarkElevated : const Color(0xFF1F2A25);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: accent.withValues(alpha: 0.55)),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                    if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        message,
                        style: TextStyle(
                          color: AColors.white.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w500,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// A themed yes/no confirmation. Returns `true` only when confirmed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    Color accent = AColors.primaryColor,
    bool destructive = false,
  }) async {
    final Color tone = destructive ? AColors.error : accent;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final c = dialogContext.padel;
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.soft(tone),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tone, size: 26),
          ),
          title: Text(title, textAlign: TextAlign.center),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, height: 1.4),
          ),
          // NOTE: `actions` is laid out by an OverflowBar, which is not a Flex —
          // putting `Expanded` directly in this list throws
          // "Incorrect use of ParentDataWidget". Hence the single Row.
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      cancelLabel,
                      style: TextStyle(color: c.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: tone),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

/// Consistent, theme-aware modal bottom sheet used by the filter/detail sheets.
///
/// Handles the drag handle, title row, rounded corners and safe-area padding so
/// individual call sites do not re-invent them (and do not forget dark mode).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  IconData? icon,
  required Widget child,
  Widget? footer,
  List<Widget> actions = const [],
  double heightFactor = 0.82,
}) {
  // Its own messenger, so snackbars raised from inside the sheet (accept a
  // request, save a form) draw above it instead of behind it.
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  AppFeedback.pushMessenger(messengerKey);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final c = sheetContext.padel;
      return ScaffoldMessenger(
        key: messengerKey,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Column(
              children: [
                // No hand-rolled drag handle here: bottomSheetTheme already
                // sets showDragHandle, and drawing our own produced two.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: c.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: AColors.primaryColor),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ...actions,
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(Icons.close_rounded, color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: c.divider),
                Expanded(child: child),
                if (footer != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border(top: BorderSide(color: c.divider)),
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(() => AppFeedback.popMessenger(messengerKey));
}
