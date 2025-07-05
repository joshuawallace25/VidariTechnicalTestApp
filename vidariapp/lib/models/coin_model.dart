class Coin {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double price;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      image: json['image'],
      price: (json['current_price'] as num).toDouble(),
    );
  }
}
