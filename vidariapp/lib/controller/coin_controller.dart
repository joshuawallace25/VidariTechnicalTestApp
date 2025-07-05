import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vidariapp/models/coin_model.dart';

class CoinController extends GetxController {
  var coins = <Coin>[].obs;
  var isLoading = true.obs;
  final box = GetStorage();
  RxList<String> favoriteIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoins();
    List? storedFavs = box.read<List>('favorites');
    if (storedFavs != null) favoriteIds.assignAll(storedFavs.cast<String>());
  }

  Future<void> fetchCoins() async {
  try {
    isLoading(true);

    final response = await http.get(Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      coins.value = data.map((json) => Coin.fromJson(json)).toList();
    } else {
    
    }
  } finally {
    isLoading(false);
  }
}


  void toggleFavorite(String id) {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }

    favoriteIds.refresh(); 
    box.write('favorites', favoriteIds);
  }

  bool isFavorite(String id) => favoriteIds.contains(id);
}
