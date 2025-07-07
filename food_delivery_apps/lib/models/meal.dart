class Meal {
  final String name;
  final String thumb;
  final String? category;
  final double price;
  final double rating;

  Meal({
    required this.name,
    required this.thumb,
    this.category,
    this.price = 0.0, // Default 0 kalau API tidak punya
    this.rating = 0.0, // Default 0 kalau API tidak punya
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['strMeal'] ?? '',
      thumb: json['strMealThumb'] ?? '',
      category: json['strCategory'],
      // Bisa random harga & rating
      price: 25000 + (5000 * (json['strMeal'].hashCode % 5)),
      rating: 4.0 + ((json['strMeal'].hashCode % 10) / 10),
    );
  }
}
