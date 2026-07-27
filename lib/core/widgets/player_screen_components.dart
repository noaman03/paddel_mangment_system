import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

// Shared Header Component
class PlayerScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final bool showNotifications;

  const PlayerScreenHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.showNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(ASizes.paddingMd),
      decoration: BoxDecoration(
        color: isDark ? AColors.dark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AColors.primaryColor,
                      AColors.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForTitle(title),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: ASizes.fontSizeLg + 2,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AColors.white : AColors.textprimary,
                ),
              ),
            ],
          ),

          // Notification Button
          if (showNotifications)
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AColors.containerDark : AColors.containerLight)
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: onNotificationTap,
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? AColors.white : AColors.darkerGrey,
                      size: 24,
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationCount > 99 ? '99+' : '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'matches':
      case 'padel matches':
        return Icons.sports_tennis;
      case 'courts':
      case 'find courts':
        return Icons.location_on;
      case 'tournaments':
        return Icons.emoji_events;
      default:
        return Icons.sports;
    }
  }
}

// Shared Search Bar Component
class PlayerSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextEditingController? controller;

  const PlayerSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AColors.containerDark : AColors.containerLight,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
        border: Border.all(
          color: isDark ? AColors.grey.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? AColors.grey : AColors.darkGrey,
            fontSize: ASizes.fontSizeMd,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AColors.grey : AColors.darkGrey,
            size: 22,
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? AColors.grey : AColors.darkGrey,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ASizes.paddingMd,
            vertical: ASizes.paddingSm + 4,
          ),
        ),
        style: TextStyle(
          color: isDark ? AColors.white : AColors.textprimary,
          fontSize: ASizes.fontSizeMd,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// Shared Tab Bar Component
class PlayerTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const PlayerTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AColors.containerDark : AColors.containerLight,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
        border: Border.all(
          color: isDark ? AColors.grey.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AColors.primaryColor,
              AColors.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
          boxShadow: [
            BoxShadow(
              color: AColors.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? AColors.grey : AColors.darkGrey,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: ASizes.fontSizeSm,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: ASizes.fontSizeSm,
        ),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }
}

// Shared Filter Button Component
class PlayerFilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool hasActiveFilters;
  final bool isExpanded;

  const PlayerFilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.hasActiveFilters = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Expanded(
      flex: isExpanded ? 2 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 18,
            color: hasActiveFilters
                ? Colors.white
                : (isDark ? AColors.white : AColors.darkGrey),
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasActiveFilters
                      ? Colors.white
                      : (isDark ? AColors.white : AColors.darkGrey),
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasActiveFilters
                ? AColors.primaryColor
                : (isDark ? AColors.containerDark : Colors.grey.shade100),
            foregroundColor: hasActiveFilters
                ? Colors.white
                : (isDark ? AColors.white : AColors.darkGrey),
            side: BorderSide(
              color: hasActiveFilters
                  ? AColors.primaryColor
                  : (isDark
                      ? AColors.grey.withOpacity(0.5)
                      : Colors.grey.shade300),
              width: hasActiveFilters ? 2.0 : 1.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            elevation: hasActiveFilters ? 4 : 0,
            shadowColor: hasActiveFilters
                ? AColors.primaryColor.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

// Shared Empty State Component
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
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASizes.paddingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? AColors.containerDark : AColors.containerLight)
                    .withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: isDark ? AColors.grey : AColors.darkGrey,
              ),
            ),
            const SizedBox(height: ASizes.spaceBtwItems),
            Text(
              title,
              style: TextStyle(
                fontSize: ASizes.fontSizeLg,
                fontWeight: FontWeight.w600,
                color: isDark ? AColors.grey : AColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ASizes.spaceBtwItems / 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? AColors.grey : AColors.darkGrey,
                fontSize: ASizes.fontSizeMd,
              ),
              textAlign: TextAlign.center,
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

// Shared Card Base Component
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
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: isDark ? AColors.containerDark : Colors.white,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: showBorder
            ? Border.all(
                color: borderColor ?? AColors.primaryColor,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(ASizes.paddingMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Shared Status Badge Component
class PlayerStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const PlayerStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ASizes.paddingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusSm),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
