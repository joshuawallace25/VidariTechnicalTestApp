import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vidariapp/app/routes/app_page.dart';
import 'package:vidariapp/app/routes/routes.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Crypto Track',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.homescreen,
      getPages: AppPages.pages,
    );
  }
}
