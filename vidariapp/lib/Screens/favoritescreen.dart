import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidariapp/controller/coin_controller.dart';

class FavoritesScreen extends StatelessWidget {
  final CoinController controller = Get.find();

  FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Coins')),
      body: Obx(() {
        final favoriteCoins = controller.coins
            .where((coin) => controller.favoriteIds.contains(coin.id))
            .toList();

        if (favoriteCoins.isEmpty) {
          return Center(child: Text('No favorite coins yet.'));
        }

        return ListView.builder(
          itemCount: favoriteCoins.length,
          itemBuilder: (context, index) {
            final coin = favoriteCoins[index];
            return ListTile(
              leading: Image.network(coin.image, width: 32, height: 32),
              title: Text('${coin.name} (${coin.symbol.toUpperCase()})'),
              subtitle: Text('\$${coin.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  controller.toggleFavorite(coin.id);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
