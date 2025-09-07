import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PreferenceCardWidget extends StatelessWidget {
  final String title;
  final String iconName;
  final Widget content;
  final VoidCallback? onTap;
  final bool isExpandable;
  final bool isExpanded;

  const PreferenceCardWidget({
    super.key,
    required this.title,
    required this.iconName,
    required this.content,
    this.onTap,
    this.isExpandable = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
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
                    child: Text(
                      title,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isExpandable)
                    CustomIconWidget(
                      iconName: isExpanded ? 'expand_less' : 'expand_more',
                      size: 6.w,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),

          // Content
          if (!isExpandable || isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: content,
            ),
        ],
      ),
    );
  }
}
