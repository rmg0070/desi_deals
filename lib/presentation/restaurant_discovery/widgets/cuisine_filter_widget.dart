import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CuisineFilterWidget extends StatelessWidget {
  final List<String> selectedCuisines;
  final Function(String) onCuisineToggle;

  const CuisineFilterWidget({
    super.key,
    required this.selectedCuisines,
    required this.onCuisineToggle,
  });

  static const List<Map<String, dynamic>> cuisineTypes = [
    {'name': 'All', 'icon': 'restaurant'},
    {'name': 'Italian', 'icon': 'local_pizza'},
    {'name': 'Asian', 'icon': 'ramen_dining'},
    {'name': 'Mexican', 'icon': 'lunch_dining'},
    {'name': 'American', 'icon': 'fastfood'},
    {'name': 'Indian', 'icon': 'curry'},
    {'name': 'Mediterranean', 'icon': 'kebab_dining'},
    {'name': 'Chinese', 'icon': 'rice_bowl'},
    {'name': 'Thai', 'icon': 'restaurant_menu'},
    {'name': 'Japanese', 'icon': 'set_meal'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: cuisineTypes.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final cuisine = cuisineTypes[index];
          final isSelected = selectedCuisines.contains(cuisine['name']);

          return GestureDetector(
            onTap: () => onCuisineToggle(cuisine['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: cuisine['icon'],
                    color: isSelected
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    cuisine['name'],
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
