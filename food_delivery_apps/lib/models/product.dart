class Product {
  final int id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final int price;
  final double? rating;
  final String? shopName;
  final bool isPromos;
  final bool isTrending;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.rating,
    this.shopName,
    required this.isPromos,
    required this.isTrending,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        description: json['description'],
        imageUrl: json['image_url'],
        price: json['price'],
        rating: (json['rating'] as num?)?.toDouble(),
        shopName: json['shop_name'],
        isPromos: json['is_promos'],
        isTrending: json['is_trending'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'image_url': imageUrl,
        'price': price,
        'rating': rating,
        'shop_name': shopName,
        'is_promos': isPromos,
        'is_trending': isTrending,
      };

  int get finalPrice {
    if (isPromos) {
      return (price * 0.9).round();
    }
    return price;
  }
}
