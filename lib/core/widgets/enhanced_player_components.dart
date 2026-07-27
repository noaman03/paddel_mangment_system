import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

// Modern Glassmorphic Header
class ModernPlayerHeader extends StatefulWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final bool showNotifications;
  final Widget? actionWidget;

  const ModernPlayerHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.showNotifications = true,
    this.actionWidget,
  });

  @override
  State<ModernPlayerHeader> createState() => _ModernPlayerHeaderState();
}

class _ModernPlayerHeaderState extends State<ModernPlayerHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.notificationCount > 0) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AColors.dark.withOpacity(0.9),
                  AColors.dark.withOpacity(0.7),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(ASizes.cardRadiusLg),
          bottomRight: Radius.circular(ASizes.cardRadiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(ASizes.cardRadiusLg),
            bottomRight: Radius.circular(ASizes.cardRadiusLg),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          ASizes.paddingMd,
          ASizes.paddingSm,
          ASizes.paddingMd,
          ASizes.paddingMd,
        ),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AColors.primaryColor,
                    AColors.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getIconForTitle(widget.title),
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Title with animation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        isDark ? AColors.white : AColors.textprimary,
                        AColors.primaryColor,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: ASizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _getSubtitleForTitle(widget.title),
                    style: TextStyle(
                      fontSize: ASizes.fontSizeSm,
                      color: (isDark ? AColors.grey : AColors.textsecondarry)
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Action widgets
            Row(
              children: [
                if (widget.actionWidget != null) ...[
                  widget.actionWidget!,
                  const SizedBox(width: 8),
                ],
                if (widget.showNotifications)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: widget.notificationCount > 0
                          ? _pulseAnimation.value
                          : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (isDark ? AColors.containerDark : Colors.white)
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                widget.onNotificationTap?.call();
                              },
                              icon: Icon(
                                Icons.notifications_outlined,
                                color:
                                    isDark ? AColors.white : AColors.darkerGrey,
                                size: 24,
                              ),
                            ),
                            if (widget.notificationCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AColors.error, Colors.redAccent],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AColors.error.withOpacity(0.5),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    widget.notificationCount > 99
                                        ? '99+'
                                        : '${widget.notificationCount}',
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
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'matches':
      case 'padel matches':
        return Icons.sports_tennis_rounded;
      case 'courts':
      case 'find courts':
        return Icons.location_on_rounded;
      case 'tournaments':
        return Icons.emoji_events_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  String _getSubtitleForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'matches':
        return 'Find and join matches';
      case 'courts':
        return 'Discover courts near you';
      case 'tournaments':
        return 'Compete and win prizes';
      default:
        return 'Explore padel world';
    }
  }
}

// Enhanced Search Bar with Auto-complete and Voice Search
class EnhancedSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final List<String>? suggestions;
  final bool showVoiceSearch;

  const EnhancedSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.suggestions,
    this.showVoiceSearch = true,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isFocused
                      ? [
                          AColors.primaryColor.withOpacity(0.1),
                          AColors.primaryColor.withOpacity(0.05),
                        ]
                      : [
                          (isDark ? AColors.containerDark : Colors.white),
                          (isDark ? AColors.containerDark : Colors.white),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isFocused
                      ? AColors.primaryColor
                      : (isDark
                          ? AColors.grey.withOpacity(0.3)
                          : Colors.grey.shade200),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused
                        ? AColors.primaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _isFocused ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: (value) {
                  widget.onChanged(value);
                  setState(() {
                    _showSuggestions = value.isNotEmpty &&
                        widget.suggestions != null &&
                        widget.suggestions!.isNotEmpty;
                  });
                },
                onTap: () {
                  setState(() => _isFocused = true);
                  _animationController.forward();
                  HapticFeedback.selectionClick();
                },
                onSubmitted: (_) {
                  setState(() => _isFocused = false);
                  _animationController.reverse();
                  FocusScope.of(context).unfocus();
                },
                style: TextStyle(
                  color: isDark ? AColors.white : AColors.textprimary,
                  fontSize: ASizes.fontSizeMd,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: isDark ? AColors.grey : AColors.darkGrey,
                    fontSize: ASizes.fontSizeMd,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: _isFocused
                          ? AColors.primaryColor
                          : (isDark ? AColors.grey : AColors.darkGrey),
                      size: 24,
                    ),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.controller?.text.isNotEmpty == true)
                        IconButton(
                          onPressed: () {
                            widget.controller?.clear();
                            widget.onChanged('');
                            setState(() => _showSuggestions = false);
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            color: isDark ? AColors.grey : AColors.darkGrey,
                            size: 20,
                          ),
                        ),
                      if (widget.showVoiceSearch)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              // Implement voice search
                            },
                            icon: const Icon(
                              Icons.mic_rounded,
                              color: AColors.primaryColor,
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions && widget.suggestions != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: isDark ? AColors.containerDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: widget.suggestions!
                  .take(5)
                  .map((suggestion) => ListTile(
                        leading: Icon(
                          Icons.history_rounded,
                          color: isDark ? AColors.grey : AColors.darkGrey,
                          size: 20,
                        ),
                        title: Text(
                          suggestion,
                          style: TextStyle(
                            color: isDark ? AColors.white : AColors.textprimary,
                            fontSize: ASizes.fontSizeMd,
                          ),
                        ),
                        onTap: () {
                          widget.controller?.text = suggestion;
                          widget.onChanged(suggestion);
                          setState(() => _showSuggestions = false);
                        },
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

// Modern Tab Bar with Sliding Indicator
class ModernTabBar extends StatefulWidget {
  final TabController controller;
  final List<String> tabs;
  final List<IconData>? icons;

  const ModernTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.icons,
  });

  @override
  State<ModernTabBar> createState() => _ModernTabBarState();
}

class _ModernTabBarState extends State<ModernTabBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    widget.controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    _slideController.animateTo(
      widget.controller.index / (widget.tabs.length - 1),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AColors.containerDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AColors.grey.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return Positioned(
                left: _slideController.value *
                    (MediaQuery.of(context).size.width - 32) /
                    widget.tabs.length,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 32) /
                      widget.tabs.length,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AColors.primaryColor,
                        AColors.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab bar
          TabBar(
            controller: widget.controller,
            indicatorColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? AColors.grey : AColors.darkGrey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: ASizes.fontSizeMd,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: ASizes.fontSizeMd,
            ),
            onTap: (index) => HapticFeedback.selectionClick(),
            tabs: widget.tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icons != null &&
                        widget.icons!.length > index) ...[
                      Icon(
                        widget.icons![index],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        tab,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Enhanced Filter Button with Animation
class EnhancedFilterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool hasActiveFilters;
  final bool isExpanded;
  final int? filterCount;

  const EnhancedFilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.hasActiveFilters = false,
    this.isExpanded = false,
    this.filterCount,
  });

  @override
  State<EnhancedFilterButton> createState() => _EnhancedFilterButtonState();
}

class _EnhancedFilterButtonState extends State<EnhancedFilterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Expanded(
      flex: widget.isExpanded ? 2 : 1,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onPressed();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: widget.hasActiveFilters
                    ? LinearGradient(
                        colors: [
                          AColors.primaryColor,
                          AColors.primaryColor.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: widget.hasActiveFilters
                    ? null
                    : (isDark ? AColors.containerDark : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.hasActiveFilters
                      ? AColors.primaryColor
                      : (isDark
                          ? AColors.grey.withOpacity(0.5)
                          : Colors.grey.shade300),
                  width: widget.hasActiveFilters ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.hasActiveFilters
                        ? AColors.primaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: widget.hasActiveFilters ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.hasActiveFilters
                        ? Colors.white
                        : (isDark ? AColors.white : AColors.darkGrey),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: ASizes.fontSizeSm,
                        fontWeight: FontWeight.w600,
                        color: widget.hasActiveFilters
                            ? Colors.white
                            : (isDark ? AColors.white : AColors.darkGrey),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.hasActiveFilters &&
                      widget.filterCount != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.filterCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else if (widget.hasActiveFilters) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Card with Better Shadows and Hover Effects
class EnhancedPlayerCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final bool showRipple;

  const EnhancedPlayerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.showRipple = true,
  });

  @override
  State<EnhancedPlayerCard> createState() => _EnhancedPlayerCardState();
}

class _EnhancedPlayerCardState extends State<EnhancedPlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 4, end: 12).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          margin: widget.margin ??
              const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AColors.containerDark,
                      AColors.containerDark.withOpacity(0.8),
                    ]
                  : [
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                    ],
            ),
            borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
            border: widget.showBorder
                ? Border.all(
                    color: widget.borderColor ?? AColors.primaryColor,
                    width: 2,
                  )
                : Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                spreadRadius: 0,
                blurRadius: _elevationAnimation.value,
                offset: Offset(0, _elevationAnimation.value / 2),
              ),
              if (!isDark)
                BoxShadow(
                  color: AColors.primaryColor.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: _elevationAnimation.value * 2,
                  offset: Offset(0, _elevationAnimation.value),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (widget.onTap != null) {
                  HapticFeedback.lightImpact();
                  widget.onTap!();
                }
              },
              onHover: (hovering) {
                if (hovering) {
                  _hoverController.forward();
                } else {
                  _hoverController.reverse();
                }
              },
              borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
              splashColor: widget.showRipple
                  ? AColors.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              highlightColor: widget.showRipple
                  ? AColors.primaryColor.withOpacity(0.05)
                  : Colors.transparent,
              child: Padding(
                padding:
                    widget.padding ?? const EdgeInsets.all(ASizes.paddingMd),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Status Badge with Glow Effect
class EnhancedStatusBadge extends StatefulWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool showGlow;

  const EnhancedStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.showGlow = true,
  });

  @override
  State<EnhancedStatusBadge> createState() => _EnhancedStatusBadgeState();
}

class _EnhancedStatusBadgeState extends State<EnhancedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.showGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ASizes.paddingSm + 2,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color,
              widget.color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(ASizes.borderRadiusSm + 2),
          boxShadow: widget.showGlow
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Empty State with Lottie-like Animation
class ModernEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const ModernEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  State<ModernEmptyState> createState() => _ModernEmptyStateState();
}

class _ModernEmptyStateState extends State<ModernEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _floatController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ASizes.paddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark
                                  ? AColors.containerDark
                                  : Colors.grey.shade100)
                              .withOpacity(0.8),
                          (isDark ? AColors.containerDark : Colors.grey.shade50)
                              .withOpacity(0.4),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 80,
                      color: (isDark ? AColors.grey : AColors.darkGrey)
                          .withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ASizes.spaceBtwSections),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: ASizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AColors.grey : AColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ASizes.spaceBtwItems),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: (isDark ? AColors.grey : AColors.darkGrey)
                      .withOpacity(0.8),
                  fontSize: ASizes.fontSizeMd,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.action != null) ...[
                const SizedBox(height: ASizes.spaceBtwSections),
                widget.action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
