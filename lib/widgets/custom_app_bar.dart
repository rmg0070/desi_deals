import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar variants for different screens
enum CustomAppBarVariant {
  discovery,
  detail,
  profile,
  dashboard,
}

/// Production-ready custom app bar widget for food discovery application
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomAppBarVariant variant;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.variant,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: _buildTitle(context),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      centerTitle: centerTitle,
      elevation: elevation ?? 0,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: foregroundColor ?? theme.appBarTheme.foregroundColor,
      ),
      iconTheme: IconThemeData(
        color: foregroundColor ?? theme.appBarTheme.foregroundColor,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? theme.appBarTheme.foregroundColor,
        size: 24,
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    switch (variant) {
      case CustomAppBarVariant.discovery:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title ?? 'Discover',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
      case CustomAppBarVariant.detail:
        return Text(
          title ?? 'Restaurant Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
      case CustomAppBarVariant.profile:
        return Text(
          title ?? 'Profile',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
      case CustomAppBarVariant.dashboard:
        return Text(
          title ?? 'Dashboard',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton || Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    // Discovery screen leading widget (location or menu)
    if (variant == CustomAppBarVariant.discovery) {
      return IconButton(
        icon: const Icon(Icons.location_on_outlined),
        onPressed: () {
          // Handle location selection
        },
        tooltip: 'Location',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) return actions;

    switch (variant) {
      case CustomAppBarVariant.discovery:
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Handle filters
            },
            tooltip: 'Filters',
          ),
          const SizedBox(width: 8),
        ];

      case CustomAppBarVariant.detail:
        return [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Handle favorite
            },
            tooltip: 'Add to Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Handle share
            },
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'report':
                  // Handle report
                  break;
                case 'directions':
                  // Handle directions
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'directions',
                child: Row(
                  children: [
                    Icon(Icons.directions),
                    SizedBox(width: 12),
                    Text('Get Directions'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report_outlined),
                    SizedBox(width: 12),
                    Text('Report Issue'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ];

      case CustomAppBarVariant.profile:
        return [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ];

      case CustomAppBarVariant.dashboard:
        return [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              // Handle analytics
            },
            tooltip: 'Analytics',
          ),
          const SizedBox(width: 8),
        ];
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
