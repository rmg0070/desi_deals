import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/deal.dart';
import '../../models/restaurant.dart';
import '../../models/user_profile.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/activity_item_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_action_button_widget.dart';
import './widgets/restaurant_selector_widget.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3;
  String? _selectedRestaurantId;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isRefreshing = false;
  UserProfile? _userProfile;  // Add this field
  List<String> _managedRestaurants = [];  // Add this field

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        UserService.getCurrentUserProfile(),
        UserService.getUserManagedRestaurants(),
      ]);

      final userProfile = results[0] as UserProfile?;
      final managedRestaurants = results[1] as List<String>;

      setState(() {
        _userProfile = userProfile;
        _managedRestaurants = managedRestaurants;
        if (managedRestaurants.isNotEmpty) {
          _selectedRestaurantId = managedRestaurants.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard: $e';
        _isLoading = false;
      });
    }
  }

  void _onRestaurantSelected(String restaurantId) {
    setState(() {
      _selectedRestaurantId = restaurantId;
    });
  }

  void _navigateToMenuManagement() {
    if (_selectedRestaurantId != null) {
      // TODO: Navigate to menu management screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu Management - Coming Soon'),
        ),
      );
    }
  }

  void _navigateToDealCreation() {
    if (_selectedRestaurantId != null) {
      // TODO: Navigate to deal creation screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deal Creation - Coming Soon'),
        ),
      );
    }
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.restaurantDiscovery);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.userProfile);
        break;
      case 2:
        // Already on dashboard
        break;
      case 3:
        // Already on dashboard
        break;
    }
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActivityDetailsModal(activity),
    );
  }

  Widget _buildActivityDetailsModal(Map<String, dynamic> activity) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    activity['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    activity['description'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics Summary',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'This activity contributed to your restaurant\'s visibility and customer engagement metrics.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.dashboard,
        title: 'Restaurant Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle add restaurant
        },
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 5.w,
        ),
        label: Text(
          'Add Restaurant',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
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
              'Error Loading Dashboard',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_managedRestaurants.isEmpty) {
      return _buildNoRestaurantsView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Selector
          if (_managedRestaurants.length > 1)
            RestaurantSelectorWidget(
              restaurants: [],
              selectedRestaurantId: _selectedRestaurantId ?? '',
              onRestaurantChanged: _onRestaurantSelected,
            ),

          if (_managedRestaurants.length > 1) SizedBox(height: 3.h),

          // Metrics Cards
          Row(
            children: [
              Expanded(
                child: MetricsCardWidget(
                  title: 'Today\'s Orders',
                  value: '24',
                  changePercentage: '+12%',
                  isPositive: true,
                  icon: Icons.shopping_cart,
                  iconColor: Colors.blue,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: MetricsCardWidget(
                  title: 'Revenue',
                  value: '\$892',
                  changePercentage: '+5.2%',
                  isPositive: true,
                  icon: Icons.attach_money,
                  iconColor: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: MetricsCardWidget(
                  title: 'Active Deals',
                  value: '3',
                  changePercentage: 'Running',
                  isPositive: true,
                  icon: Icons.local_offer,
                  iconColor: Colors.orange,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: MetricsCardWidget(
                  title: 'Rating',
                  value: '4.5',
                  changePercentage: '+0.2',
                  isPositive: true,
                  icon: Icons.star,
                  iconColor: Colors.amber,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 2.h),

          Row(
            children: [
              QuickActionButtonWidget(
                title: 'Menu Management',
                icon: Icons.restaurant_menu,
                backgroundColor: Colors.blue,
                onTap: _navigateToMenuManagement,
              ),
              SizedBox(width: 2.w),
              QuickActionButtonWidget(
                title: 'Deal Creation',
                icon: Icons.local_offer,
                backgroundColor: Colors.orange,
                onTap: _navigateToDealCreation,
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Recent Activity
          Text(
            'Recent Activity',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 2.h),

          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildNoRestaurantsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 20.w,
            color: Colors.grey,
          ),
          SizedBox(height: 3.h),
          Text(
            'No Restaurants to Manage',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'You don\'t have access to manage any restaurants. Contact your administrator to get access.',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.restaurantDiscovery);
            },
            child: const Text('Explore Restaurants'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // Mock recent activity data
    final activities = [
      {
        'title': 'New order received',
        'subtitle': 'Order #1234 - \$24.99',
        'time': '2 min ago',
        'icon': Icons.shopping_cart,
      },
      {
        'title': 'Menu item updated',
        'subtitle': 'Butter Chicken price changed',
        'time': '15 min ago',
        'icon': Icons.edit,
      },
      {
        'title': 'Deal activated',
        'subtitle': '20% Off Lunch special is now live',
        'time': '1 hour ago',
        'icon': Icons.local_offer,
      },
      {
        'title': 'New review received',
        'subtitle': '5 stars - "Amazing food!"',
        'time': '2 hours ago',
        'icon': Icons.star,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ActivityItemWidget(
          activity: {
            'title': activity['title'] as String,
            'description': activity['subtitle'] as String,
            'type': 'general',
            'timestamp': DateTime.now().subtract(Duration(minutes: index * 30)),
            'value': null,
          },
        );
      },
    );
  }
}