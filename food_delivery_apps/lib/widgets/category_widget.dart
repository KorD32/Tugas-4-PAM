import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/search_provider_product.dart';
import '../screens/list_product_screen.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((cat) {
          final label = cat['label'] as String;
          final icon = cat['icon'] as IconData;

          return GestureDetector(
            onTap: () {
              // ✅ Set kategori
              context.read<CategoryProvider>().setCategory(label);
              // ✅ Reset pencarian
              context.read<SearchProductProvider>().updateSearch('');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ListProductScreen(),
                ),
              );
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: const Color(0xFF9038FF), size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
