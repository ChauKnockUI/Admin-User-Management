import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/add_user_page.dart';
import '../pages/user_list_page.dart';
import '../pages/profile_page.dart';
import '../../domain/entities/user.dart';

class AppRoutes {
  static const String login = '/';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String addUser = '/add';
  static const String list = '/list';
  static const String profile = '/profile';
}

class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case AppRoutes.main:
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => DashboardPage());
      case AppRoutes.addUser:
        final user = settings.arguments as UserEntity?;
        return MaterialPageRoute(builder: (_) => AddUserPage(editing: user));
      case AppRoutes.list:
        return MaterialPageRoute(builder: (_) => UserListPage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      default:
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}
