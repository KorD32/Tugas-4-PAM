import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider_product.dart';
import '../providers/category_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/meal_provider.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    final searchProvider = context.read<SearchProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final mealProvider = context.read<MealProvider>();

    categoryProvider.clearCategory();

    searchProvider.updateSearch(trimmed);
    await searchProvider.fetchProducts();

    if (searchProvider.products.isEmpty) {
      await mealProvider.fetchMealsByName(trimmed);
    } else {
      mealProvider.clearMeals();
    }

    if (mounted) {
      _controller.clear();
      Navigator.pushNamed(context, '/list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF9038FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF9038FF), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<UserProfileProvider>(
                  builder: (context, userProfile, child) {
                    final username = userProfile.username.isNotEmpty
                        ? userProfile.username
                        : 'User';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang, $username!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Temukan makanan favoritmu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wallet, color: Color(0xFF9038FF), size: 18),
                    SizedBox(width: 5),
                    Text(
                      'Rp 50.000',
                      style: TextStyle(
                        color: Color(0xFF9038FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onSubmitted: _onSubmit,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Cari makanan atau resto...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          )
        ],
      ),
    );
  }
}
