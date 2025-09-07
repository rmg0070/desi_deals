import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RestaurantHoursTab extends StatelessWidget {
  final Map<String, dynamic> hoursData;

  const RestaurantHoursTab({
    super.key,
    required this.hoursData,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> weeklyHours =
        hoursData['weeklyHours'] as Map<String, dynamic>;
    final List<Map<String, dynamic>> specialHours =
        (hoursData['specialHours'] as List).cast<Map<String, dynamic>>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyHoursSection(context, weeklyHours),
          if (specialHours.isNotEmpty) ...[
            SizedBox(height: 4.h),
            _buildSpecialHoursSection(context, specialHours),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyHoursSection(
      BuildContext context, Map<String, dynamic> weeklyHours) {
    final List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Regular Hours',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: daysOfWeek.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final dayKey = day.toLowerCase();
              final dayHours = weeklyHours[dayKey] as Map<String, dynamic>?;

              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: AppTheme.borderLight,
                    ),
                  _buildDayHoursRow(context, day, dayHours),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHoursRow(
      BuildContext context, String day, Map<String, dynamic>? dayHours) {
    final bool isToday = _isToday(day);
    final bool isClosed = dayHours == null || dayHours['isClosed'] == true;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                color: isToday
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.textPrimaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isClosed
                ? Text(
                    'Closed',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.dangerLight,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  )
                : _buildHoursText(context, dayHours, isToday),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursText(
      BuildContext context, Map<String, dynamic> dayHours, bool isToday) {
    final List<Map<String, dynamic>> intervals =
        (dayHours['intervals'] as List).cast<Map<String, dynamic>>();

    if (intervals.isEmpty) {
      return Text(
        'Closed',
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.dangerLight,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.right,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: intervals.map((interval) {
        final String openTime = interval['open'] as String;
        final String closeTime = interval['close'] as String;

        return Text(
          '$openTime - $closeTime',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: isToday
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.textPrimaryLight,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecialHoursSection(
      BuildContext context, List<Map<String, dynamic>> specialHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Hours',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentLight.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: specialHours.asMap().entries.map((entry) {
              final index = entry.key;
              final specialHour = entry.value;

              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: AppTheme.accentLight.withValues(alpha: 0.2),
                    ),
                  _buildSpecialHourRow(context, specialHour),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialHourRow(
      BuildContext context, Map<String, dynamic> specialHour) {
    final String date = specialHour['date'] as String;
    final String reason = specialHour['reason'] as String;
    final bool isClosed = specialHour['isClosed'] as bool;
    final String? openTime = specialHour['openTime'] as String?;
    final String? closeTime = specialHour['closeTime'] as String?;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'event',
                color: AppTheme.accentLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  date,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                isClosed ? 'Closed' : '$openTime - $closeTime',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isClosed
                      ? AppTheme.dangerLight
                      : AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: Text(
              reason,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final todayIndex = now.weekday - 1; // DateTime.weekday is 1-7, we need 0-6
    return weekdays[todayIndex] == day;
  }
}
