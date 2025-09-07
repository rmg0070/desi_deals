import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../models/buffet.dart';
import '../../models/deal.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../models/restaurant_hours.dart';
import '../../services/restaurant_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/action_buttons_bar.dart';
import './widgets/restaurant_deals_tab.dart';
import './widgets/restaurant_hero_section.dart';
import './widgets/restaurant_hours_tab.dart';
import './widgets/restaurant_menu_tab.dart';
import './widgets/restaurant_overview_tab.dart';

class RestaurantDetail extends StatefulWidget {
  const RestaurantDetail({super.key});

  @override
  State<RestaurantDetail> createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State variables
  Restaurant? _restaurant;
  List<Deal> _deals = [];
  List<Buffet> _buffets = [];
  List<MenuCategory> _menuCategories = [];
  List<RestaurantHours> _hours = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final restaurantId = ModalRoute.of(context)!.settings.arguments as String?;
    if (restaurantId != null && _restaurant == null) {
      _loadRestaurantData(restaurantId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantData(String restaurantId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        RestaurantService.getRestaurantById(restaurantId),
        RestaurantService.getDealsNow(restaurantId),
        RestaurantService.getBuffetToday(restaurantId),
        RestaurantService.getRestaurantMenu(restaurantId),
        RestaurantService.getRestaurantHours(restaurantId),
      ]);

      setState(() {
        _restaurant = results[0] as Restaurant?;
        _deals = results[1] as List<Deal>;
        _buffets = results[2] as List<Buffet>;
        _menuCategories = results[3] as List<MenuCategory>;
        _hours = results[4] as List<RestaurantHours>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load restaurant details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showSnackBar('Could not make phone call');
      }
    } catch (e) {
      _showSnackBar('Error making phone call');
    }
  }

  Future<void> _openWebsite(String websiteUrl) async {
    try {
      final Uri uri = Uri.parse(websiteUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open website');
      }
    } catch (e) {
      _showSnackBar('Error opening website');
    }
  }

  Future<void> _openMaps(String mapsUrl) async {
    try {
      final Uri uri = Uri.parse(mapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open maps');
      }
    } catch (e) {
      _showSnackBar('Error opening maps');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          variant: CustomAppBarVariant.detail,  // Add required variant parameter
          title: 'Restaurant Details',
          showBackButton: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty || _restaurant == null) {
      return Scaffold(
        appBar: CustomAppBar(
          variant: CustomAppBarVariant.detail,  // Add required variant parameter
          title: 'Restaurant Details',
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 15.w,
                color: Colors.grey,
              ),
              SizedBox(height: 2.h),
              Text(
                'Error Loading Restaurant',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  _errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'Restaurant not found',
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 35.h,
            floating: false,
            pinned: true,
            flexibleSpace: RestaurantHeroSection(
              restaurant: _restaurant!.toJson(),  // Convert Restaurant to Map<String, dynamic>
            ),
          ),
        ],
        body: Column(
          children: [
            // Action buttons
            ActionButtonsBar(
              restaurant: _restaurant!.toJson(),  // Convert Restaurant to Map<String, dynamic>
            ),

            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(
                      text:
                          'Deals${_deals.isNotEmpty ? ' (${_deals.length})' : ''}'),
                  Tab(
                      text:
                          'Buffet${_buffets.isNotEmpty ? ' (${_buffets.length})' : ''}'),
                  Tab(
                      text:
                          'Menu${_menuCategories.isNotEmpty ? ' (${_menuCategories.length})' : ''}'),
                  const Tab(text: 'Hours'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RestaurantDealsTab(deals: _deals.map((deal) => deal.toJson()).toList()),  // Convert List<Deal> to List<Map<String, dynamic>>
                  RestaurantOverviewTab(restaurant: _restaurant!.toJson()),  // Remove buffets parameter and use restaurant data
                  RestaurantMenuTab(menuCategories: _menuCategories.map((category) => category.toJson()).toList()),  // Convert List<MenuCategory> to List<Map<String, dynamic>>
                  RestaurantHoursTab(hoursData: {'weeklyHours': {}, 'specialHours': []}),  // Remove hours parameter and use hoursData
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}