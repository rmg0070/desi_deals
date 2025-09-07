import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab bar variants for different use cases
enum CustomTabBarVariant {
  cuisine,
  category,
  filter,
  dashboard,
}

/// Tab item data
class TabItem {
  final String label;
  final IconData? icon;
  final String? value;
  final int? count;

  const TabItem({
    required this.label,
    this.icon,
    this.value,
    this.count,
  });
}

/// Production-ready custom tab bar widget for food discovery application
class CustomTabBar extends StatelessWidget {
  final CustomTabBarVariant variant;
  final List<TabItem>? customTabs;
  final int selectedIndex;
  final Function(int)? onTap;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double? height;

  const CustomTabBar({
    super.key,
    required this.variant,
    this.customTabs,
    required this.selectedIndex,
    this.onTap,
    this.isScrollable = true,
    this.padding,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tabs = customTabs ?? _getDefaultTabs();

    return Container(
      height: height ?? 48,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      color: backgroundColor ?? Colors.transparent,
      child: isScrollable
          ? _buildScrollableTabBar(context, tabs, theme, colorScheme)
          : _buildFixedTabBar(context, tabs, theme, colorScheme),
    );
  }

  Widget _buildScrollableTabBar(
    BuildContext context,
    List<TabItem> tabs,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              right: index < tabs.length - 1 ? 12 : 0,
            ),
            child: _buildTabChip(context, tab, index, theme, colorScheme),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFixedTabBar(
    BuildContext context,
    List<TabItem> tabs,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        return Expanded(
          child: _buildTabChip(context, tab, index, theme, colorScheme),
        );
      }).toList(),
    );
  }

  Widget _buildTabChip(
    BuildContext context,
    TabItem tab,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = index == selectedIndex;
    final chipColor = isSelected
        ? (selectedColor ?? colorScheme.primary)
        : (unselectedColor ?? colorScheme.onSurface.withValues(alpha: 0.6));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap?.call(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tab.icon != null) ...[
                  Icon(
                    tab.icon,
                    size: 16,
                    color: chipColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  tab.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: chipColor,
                  ),
                ),
                if (tab.count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${tab.count}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TabItem> _getDefaultTabs() {
    switch (variant) {
      case CustomTabBarVariant.cuisine:
        return const [
          TabItem(label: 'All', icon: Icons.restaurant),
          TabItem(label: 'Italian', icon: Icons.local_pizza),
          TabItem(label: 'Asian', icon: Icons.ramen_dining),
          TabItem(label: 'Mexican', icon: Icons.lunch_dining),
          TabItem(label: 'American', icon: Icons.fastfood),
          TabItem(label: 'Indian', icon: Icons.help_outline),
          TabItem(label: 'Mediterranean', icon: Icons.kebab_dining),
        ];

      case CustomTabBarVariant.category:
        return const [
          TabItem(label: 'Nearby', icon: Icons.location_on, count: 24),
          TabItem(label: 'Popular', icon: Icons.trending_up, count: 18),
          TabItem(label: 'Deals', icon: Icons.local_offer, count: 12),
          TabItem(label: 'New', icon: Icons.fiber_new, count: 8),
          TabItem(label: 'Open Now', icon: Icons.access_time, count: 32),
        ];

      case CustomTabBarVariant.filter:
        return const [
          TabItem(label: 'Price', icon: Icons.attach_money),
          TabItem(label: 'Rating', icon: Icons.star),
          TabItem(label: 'Distance', icon: Icons.location_on),
          TabItem(label: 'Delivery', icon: Icons.delivery_dining),
          TabItem(label: 'Dietary', icon: Icons.eco),
        ];

      case CustomTabBarVariant.dashboard:
        return const [
          TabItem(label: 'Overview', icon: Icons.dashboard),
          TabItem(label: 'Orders', icon: Icons.receipt_long, count: 15),
          TabItem(label: 'Menu', icon: Icons.restaurant_menu),
          TabItem(label: 'Reviews', icon: Icons.rate_review, count: 8),
          TabItem(label: 'Analytics', icon: Icons.analytics),
        ];
    }
  }
}
