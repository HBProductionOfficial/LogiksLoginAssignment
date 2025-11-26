import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/error_state_widget.dart';
import './widgets/expanded_product_details_widget.dart';
import './widgets/loading_skeleton_widget.dart';
import './widgets/product_card_widget.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _products = [];
  Set<String> _updatedProductIds = {};
  String? _expandedProductId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _updateTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      final response = await _dio.get(
        'https://api.restful-api.dev/objects',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _products = data.map((item) {
            return {
              'id': item['id']?.toString() ?? '',
              'name': item['name']?.toString() ?? 'Unknown Product',
              'data': item['data'] is Map
                  ? Map<String, dynamic>.from(item['data'] as Map)
                  : null,
              'originalData': item['data'] is Map
                  ? Map<String, dynamic>.from(item['data'] as Map)
                  : null,
            };
          }).toList();
          _isLoading = false;
          _hasError = false;
        });
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('No internet connection')) {
      return 'No internet connection. Please check your network settings.';
    } else if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timeout. Please try again.';
      } else if (error.type == DioExceptionType.badResponse) {
        return 'Server error. Please try again later.';
      }
    }
    return 'Failed to load products. Please try again.';
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_products.isEmpty) return;

      setState(() {
        for (var product in _products) {
          if (product['data'] != null) {
            final data = product['data'] as Map<String, dynamic>;
            final originalData =
                product['originalData'] as Map<String, dynamic>?;

            bool hasChanges = false;
            data.forEach((key, value) {
              if (value is num) {
                final newValue = value +
                    (value * 0.01 * (DateTime.now().millisecond % 10 - 5));
                if ((newValue - value).abs() > 0.01) {
                  data[key] = num.parse(newValue.toStringAsFixed(2));
                  hasChanges = true;
                }
              }
            });

            if (hasChanges && originalData != null) {
              bool isDifferent = false;
              data.forEach((key, value) {
                if (originalData[key] != value) {
                  isDifferent = true;
                }
              });

              if (isDifferent) {
                _updatedProductIds.add(product['id'] as String);
              }
            }
          }
        }
      });
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
      _updatedProductIds.clear();
      _expandedProductId = null;
    });

    await _fetchProducts();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _toggleExpanded(String productId) {
    setState(() {
      if (_expandedProductId == productId) {
        _expandedProductId = null;
      } else {
        _expandedProductId = productId;
        _updatedProductIds.remove(productId);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final index = _products.indexWhere((p) => p['id'] == productId);
          if (index != -1 && _scrollController.hasClients) {
            final itemHeight = 20.h;
            final targetOffset = index * itemHeight;
            _scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Logout',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to logout? You will need to authenticate again to access your products.',
            style: theme.textTheme.bodyMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login-screen',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(
                'Logout',
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Product Catalog',
        subtitle: 'Updated: Nov 26, 2025',
        variant: CustomAppBarVariant.productList,
        onLogoutPressed: _handleLogout,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading && !_isRefreshing) {
      return const LoadingSkeletonWidget();
    }

    if (_hasError) {
      return ErrorStateWidget(
        errorMessage: _errorMessage,
        onRetry: _fetchProducts,
      );
    }

    if (_products.isEmpty) {
      return ErrorStateWidget(
        errorMessage: 'No products available at the moment.',
        onRetry: _fetchProducts,
        isEmptyState: true,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final productId = product['id'] as String;
          final isExpanded = _expandedProductId == productId;
          final hasUpdate = _updatedProductIds.contains(productId);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(bottom: 2.h),
            child: Column(
              children: [
                ProductCardWidget(
                  productId: productId,
                  productName: product['name'] as String,
                  isExpanded: isExpanded,
                  hasUpdate: hasUpdate,
                  onTap: () => _toggleExpanded(productId),
                ),
                if (isExpanded && product['data'] != null)
                  ExpandedProductDetailsWidget(
                    productData: product['data'] as Map<String, dynamic>,
                    originalData:
                        product['originalData'] as Map<String, dynamic>?,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
