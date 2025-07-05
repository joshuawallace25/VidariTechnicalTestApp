import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidariapp/app/routes/routes.dart';
import 'package:vidariapp/controller/coin_controller.dart';

class Homescreen extends StatelessWidget {
  final CoinController controller = Get.put(CoinController());

   Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CryptoTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () => Get.toNamed(AppRoutes.favoritescreen),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.coins.length,
          itemBuilder: (context, index) {
            final coin = controller.coins[index];
            // ignore: unnecessary_null_comparison
            if (coin == null) return const SizedBox.shrink();
            return _buildCoinCard(context, coin);
          },
        );
      }),
    );
  }

  Widget _buildCoinCard(BuildContext context, dynamic coin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            coin.image,
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
          ),
        ),
        title: Text(
          coin.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '${coin.symbol.toUpperCase()} • \$${coin.price.toStringAsFixed(2)}',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        trailing: Obx(() => IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  controller.isFavorite(coin.id) ? Icons.star : Icons.star_border,
                  key: ValueKey<bool>(controller.isFavorite(coin.id)),
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              onPressed: () => controller.toggleFavorite(coin.id),
            )),
      ),
    );
  }
}