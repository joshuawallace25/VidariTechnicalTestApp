import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidariapp/controller/coin_controller.dart';


class Homescreen extends StatelessWidget {
  final controller = Get.put(CoinController());

   Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CryptoTrack'),
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () => Get.to(() =>Get.toNamed('/favoritescreen')),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.coins.length,
          itemBuilder: (context, index) {
            final coin = controller.coins[index];
            return ListTile(
              leading: Image.network(coin.image, width: 32, height: 32),
              title: Text('${coin.name} (${coin.symbol.toUpperCase()})'),
              subtitle: Text('\$${coin.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(
                  controller.isFavorite(coin.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => controller.toggleFavorite(coin.id),
              ),
            );
          },
        );
      }),
    );
  }
}
