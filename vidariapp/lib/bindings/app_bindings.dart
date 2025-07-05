// lib/bindings/app_binding.dart
import 'package:get/get.dart';
import 'package:vidariapp/controller/coin_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinController>(() => CoinController());
  }
}
