// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:vidariapp/Screens/favoritescreen.dart';
import 'package:vidariapp/Screens/homescreen.dart';
import 'package:vidariapp/app/routes/routes.dart';
import 'package:vidariapp/bindings/app_bindings.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.homescreen,
      page: () => Homescreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: AppRoutes.favoritescreen,
      page: () => FavoritesScreen(),
    ),
  ];
}
