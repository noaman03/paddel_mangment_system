import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// Decorative brand blobs used behind the auth screens.
///
/// This helper is deliberately **layout neutral**: it returns a plain
/// `Stack` (behind an [IgnorePointer]) rather than a `Positioned.fill`.
/// Every call site already wraps it in its own `Positioned.fill`, and two
/// `Positioned` widgets applying parent data to the same `RenderStack` throws
/// "Incorrect use of ParentDataWidget" — which took down the whole signup flow.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     Positioned.fill(child: buildBackgroundDecoration(isDark)),
///     ...content,
///   ],
/// )
/// ```
Widget buildBackgroundDecoration(bool isDark) {
  return IgnorePointer(
    // LayoutBuilder keeps this free of `Get.context!`, which was being read
    // during build and crashes whenever the helper is used outside a route.
    child: LayoutBuilder(
      builder: (context, constraints) {
        final double height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;

        return Stack(
          children: [
            // Top right blob
            Positioned(
              top: -100,
              right: -100,
              child: _Blob(
                size: 200,
                color: AColors.primaryColor,
                opacity: isDark ? 0.14 : 0.20,
              ),
            ),

            // Bottom left blob
            Positioned(
              bottom: -150,
              left: -150,
              child: _Blob(
                size: 300,
                color: AColors.primaryColor,
                opacity: isDark ? 0.10 : 0.14,
              ),
            ),

            // Middle right accent
            Positioned(
              top: height * 0.4,
              right: -50,
              child: _Blob(
                size: 100,
                color: isDark ? AColors.primaryLight : AColors.primaryDark,
                opacity: isDark ? 0.16 : 0.16,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.15),
          ],
        ),
      ),
    );
  }
}
