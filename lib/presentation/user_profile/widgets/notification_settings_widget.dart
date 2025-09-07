import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final Map<String, bool> notificationSettings;
  final Function(String, bool) onSettingChanged;

  const NotificationSettingsWidget({
    super.key,
    required this.notificationSettings,
    required this.onSettingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settings = [
      {
        'key': 'dealAlerts',
        'title': 'Deal Alerts',
        'subtitle': 'Get notified about new deals and discounts',
        'icon': 'local_offer',
      },
      {
        'key': 'buffetUpdates',
        'title': 'Buffet Updates',
        'subtitle': 'Notifications about buffet timings and menus',
        'icon': 'restaurant',
      },
      {
        'key': 'newRestaurants',
        'title': 'New Restaurants',
        'subtitle': 'Alert when new restaurants join near you',
        'icon': 'store',
      },
      {
        'key': 'weeklyDigest',
        'title': 'Weekly Digest',
        'subtitle': 'Summary of deals and restaurants you might like',
        'icon': 'email',
      },
    ];

    return Column(
      children: settings.map((setting) {
        final key = setting['key'] as String;
        final isEnabled = notificationSettings[key] ?? false;

        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppTheme.lightTheme.colorScheme.primaryContainer
                      : AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: setting['icon'] as String,
                  size: 5.w,
                  color: isEnabled
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting['title'] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      setting['subtitle'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) => onSettingChanged(key, value),
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                activeTrackColor:
                    AppTheme.lightTheme.colorScheme.primaryContainer,
                inactiveThumbColor: AppTheme.lightTheme.colorScheme.outline,
                inactiveTrackColor:
                    AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
