import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/product_list_screen/product_list_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login-screen';
  static const String productList = '/product-list-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    login: (context) => const LoginScreen(),
    productList: (context) => const ProductListScreen(),
  };
}
