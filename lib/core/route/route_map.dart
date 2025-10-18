import 'package:flutter/material.dart';
import '../../screens/intro_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/home_screen.dart';
import 'route_names.dart';

class AppRouteMap {
  static Map<String, Widget Function(BuildContext)> routes = {
    RouteNames.initial: (_) => const IntroScreen(),
    RouteNames.login: (_) => const LoginScreen(),
    RouteNames.register: (_) => const RegisterScreen(),
    RouteNames.home: (_) => const HomeScreen(),
  };
}
