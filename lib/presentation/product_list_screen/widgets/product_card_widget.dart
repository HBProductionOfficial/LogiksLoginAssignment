import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProductCardWidget extends StatelessWidget {
  final String productId;
  final String productName;
  final bool isExpanded;
  final bool hasUpdate;
  final VoidCallback onTap;

  const ProductCardWidget({
    super.key,
    required this.productId,
    required this.productName,
    required this.isExpanded,
    required this.hasUpdate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.light
                    ? Colors.black.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.08),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: $productId',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      productName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              if (hasUpdate && !isExpanded)
                Container(
                  width: 2.w,
                  height: 2.w,
                  margin: EdgeInsets.only(right: 2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
