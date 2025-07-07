import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider_product.dart';
import '../providers/category_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_widget.dart';
import '../models/meal.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SearchProductProvider>(context, listen: false);
      if (searchProvider.products.isEmpty) {
        searchProvider.fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });

    Provider.of<SearchProductProvider>(context, listen: false).updateSearch('');
  }

  void _onSearchChanged(String value) async {
    final trimmed = value.trim();
    final searchProvider =
        Provider.of<SearchProductProvider>(context, listen: false);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    categoryProvider.clearCategory();
    searchProvider.updateSearch(trimmed);
    await searchProvider.fetchProducts();

    if (searchProvider.products.isEmpty) {
      await mealProvider.fetchMealsByName(trimmed);
    } else {
      mealProvider.clearMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final mealProvider = context.watch<MealProvider>();

    final selectedCategory = categoryProvider.selectedCategory;

    final products = searchProvider.products;

    final meals = mealProvider.meals;

    final filteredProducts = selectedCategory == null
        ? products
        : products
            .where((product) =>
                product.category.toLowerCase() ==
                selectedCategory.toLowerCase())
            .toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onSubmitted: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Cari makanan...',
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                )
              : const Text('List Produk'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                _isSearching ? _stopSearch() : _startSearch();
              },
            ),
          ],
        ),
        body: searchProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildCategoryChips(categoryProvider),
                  Expanded(
                    child: (filteredProducts.isEmpty && meals.isEmpty)
                        ? const Center(child: Text("Produk tidak ditemukan"))
                        : ListView.builder(
                            itemCount: filteredProducts.isNotEmpty
                                ? filteredProducts.length
                                : meals.length,
                            itemBuilder: (_, index) {
                              if (filteredProducts.isNotEmpty) {
                                final product = filteredProducts[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {},
                                );
                              } else {
                                final Meal meal = meals[index];
                                return ListTile(
                                  leading: Image.network(
                                    meal.thumb,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(meal.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(meal.category ?? ''),
                                      Text(
                                          '⭐ ${meal.rating.toStringAsFixed(1)}'),
                                      Text(
                                          'Rp ${meal.price.toStringAsFixed(0)}'),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: const BottomNavWidget(),
      ),
    );
  }

  Widget _buildCategoryChips(CategoryProvider provider) {
    final categories = provider.categories;
    final selected = provider.selectedCategory;

    return categories.isEmpty
        ? const SizedBox.shrink()
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: selected == null,
                  onSelected: (_) {
                    provider.clearCategory();
                    _searchController.clear();
                    Provider.of<SearchProductProvider>(context, listen: false)
                        .updateSearch('');
                    setState(() {
                      _isSearching = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selected == cat,
                        onSelected: (_) {
                          provider.setCategory(cat);
                          _searchController.clear();
                          Provider.of<SearchProductProvider>(context,
                                  listen: false)
                              .updateSearch('');
                          setState(() {
                            _isSearching = false;
                          });
                        },
                      ),
                    )),
              ],
            ),
          );
  }
}
