import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ExpandedProductDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> productData;
  final Map<String, dynamic>? originalData;

  const ExpandedProductDetailsWidget({
    super.key,
    required this.productData,
    this.originalData,
  });

  bool _hasValueChanged(String key, dynamic value) {
    if (originalData == null) return false;
    return originalData![key] != value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (productData.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            'No additional details available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.all(4.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          ...productData.entries.map((entry) {
            final hasChanged = _hasValueChanged(entry.key, entry.value);
            return _buildDetailRow(
              context,
              entry.key,
              entry.value,
              hasChanged,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String key,
    dynamic value,
    bool hasChanged,
  ) {
    final theme = Theme.of(context);
    final displayValue = _formatValue(value);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: hasChanged
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: hasChanged
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatKey(key),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            flex: 3,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: hasChanged
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: hasChanged ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(
                displayValue,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }
    if (value is List) {
      return value.join(', ');
    }
    if (value is Map) {
      return value.entries
          .map((e) =>
              '${_formatKey(e.key.toString())}: ${_formatValue(e.value)}')
          .join(', ');
    }
    return value.toString();
  }
}
