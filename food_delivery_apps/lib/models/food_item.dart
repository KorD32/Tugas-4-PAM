class FoodItem {
  final String id;
  final String name;
  final String imageUrl;

  FoodItem({required this.id, required this.name, required this.imageUrl});

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['idMeal'] ?? json['id'],
        name: json['strMeal'] ?? json['name'],
        imageUrl: json['strMealThumb'] ?? json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'idMeal': id,
        'strMeal': name,
        'strMealThumb': imageUrl,
      };
}
