import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountOptionsWidget extends StatelessWidget {
  final Function(String) onOptionTap;

  const AccountOptionsWidget({
    super.key,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'key': 'editProfile',
        'title': 'Edit Profile',
        'subtitle': 'Update name, email, and phone number',
        'icon': 'edit',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'key': 'changePassword',
        'title': 'Change Password',
        'subtitle': 'Update your account password',
        'icon': 'lock',
        'color': AppTheme.lightTheme.colorScheme.secondary,
      },
      {
        'key': 'privacySettings',
        'title': 'Privacy Settings',
        'subtitle': 'Manage data sharing and privacy preferences',
        'icon': 'privacy_tip',
        'color': AppTheme.lightTheme.colorScheme.tertiary,
      },
      {
        'key': 'logout',
        'title': 'Logout',
        'subtitle': 'Sign out of your account',
        'icon': 'logout',
        'color': AppTheme.lightTheme.colorScheme.error,
      },
    ];

    return Column(
      children: options.map((option) {
        final key = option['key'] as String;
        final isLogout = key == 'logout';

        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onOptionTap(key),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isLogout
                        ? AppTheme.lightTheme.colorScheme.error
                            .withValues(alpha: 0.3)
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color:
                            (option['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: option['icon'] as String,
                        size: 5.w,
                        color: option['color'] as Color,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['title'] as String,
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isLogout
                                  ? AppTheme.lightTheme.colorScheme.error
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            option['subtitle'] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: isLogout
                                  ? AppTheme.lightTheme.colorScheme.error
                                      .withValues(alpha: 0.7)
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 5.w,
                      color: isLogout
                          ? AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.7)
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
