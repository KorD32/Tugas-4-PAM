import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.fastfood, 'label': 'Fastfood'},
      {'icon': Icons.eco, 'label': 'Vegan'},
      {'icon': Icons.restaurant_menu, 'label': 'Western'},
      {'icon': Icons.icecream, 'label': 'Dessert'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((cat) {
          return Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(cat['icon'] as IconData,
                    color: Color(0xFF9038FF), size: 30),
              ),
              const SizedBox(height: 8),
              Text(cat['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          );
        }).toList(),
      ),
    );
  }
}
