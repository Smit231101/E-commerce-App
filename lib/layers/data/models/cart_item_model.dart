class CartItemModel {
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.quantity = 1,
  });

  // To save a both SharedPreferences AND Firestore
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'quantity': quantity,
    };
  }

  // for read from both SharedPreferences AND Firestore
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json["productId"] as int,
      title: json["title"] as String,
      price: (json['price'] as num).toDouble(),
      thumbnail: json["thumbnail"] as String,
      quantity: json["quantity"] as int,
    );
  }
}
