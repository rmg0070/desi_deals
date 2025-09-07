import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppSettingsWidget extends StatelessWidget {
  final Map<String, dynamic> appSettings;
  final Function(String, dynamic) onSettingChanged;

  const AppSettingsWidget({
    super.key,
    required this.appSettings,
    required this.onSettingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Distance Units
        _buildSettingRow(
          context,
          'Distance Units',
          'Choose between miles and kilometers',
          'straighten',
          DropdownButton<String>(
            value: appSettings['distanceUnit'] as String? ?? 'miles',
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'miles', child: Text('Miles')),
              DropdownMenuItem(value: 'kilometers', child: Text('Kilometers')),
            ],
            onChanged: (value) {
              if (value != null) {
                onSettingChanged('distanceUnit', value);
              }
            },
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            dropdownColor: AppTheme.lightTheme.colorScheme.surface,
          ),
        ),

        SizedBox(height: 2.h),

        // Push Notifications
        _buildSettingRow(
          context,
          'Push Notifications',
          'Enable or disable all push notifications',
          'notifications',
          Switch(
            value: appSettings['pushNotifications'] as bool? ?? true,
            onChanged: (value) => onSettingChanged('pushNotifications', value),
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor: AppTheme.lightTheme.colorScheme.primaryContainer,
            inactiveThumbColor: AppTheme.lightTheme.colorScheme.outline,
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          ),
        ),

        SizedBox(height: 2.h),

        // Location Sharing
        _buildSettingRow(
          context,
          'Location Sharing',
          'Allow app to access your location for better recommendations',
          'location_on',
          Switch(
            value: appSettings['locationSharing'] as bool? ?? true,
            onChanged: (value) => onSettingChanged('locationSharing', value),
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor: AppTheme.lightTheme.colorScheme.primaryContainer,
            inactiveThumbColor: AppTheme.lightTheme.colorScheme.outline,
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          ),
        ),

        SizedBox(height: 2.h),

        // Dark Mode
        _buildSettingRow(
          context,
          'Dark Mode',
          'Switch between light and dark theme',
          'dark_mode',
          Switch(
            value: appSettings['darkMode'] as bool? ?? false,
            onChanged: (value) => onSettingChanged('darkMode', value),
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor: AppTheme.lightTheme.colorScheme.primaryContainer,
            inactiveThumbColor: AppTheme.lightTheme.colorScheme.outline,
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    Widget control,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            size: 5.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        control,
      ],
    );
  }
}
