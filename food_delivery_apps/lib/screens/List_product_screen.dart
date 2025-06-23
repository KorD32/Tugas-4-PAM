import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider_product.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_widget.dart';
import 'detail_screen.dart';

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
      final provider =
          Provider.of<SearchProductProvider>(context, listen: false);
      if (provider.products.isEmpty) {
        provider.fetchProducts();
      }
    });
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

  void _onSubmitted(String value) {
    Provider.of<SearchProductProvider>(context, listen: false)
        .updateSearch(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<SearchProductProvider>();
    final products = productProvider.products;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_isSearching) _stopSearch();
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onSubmitted: _onSubmitted,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Cari makanan...',
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                )
              : const Text('List Product'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                _isSearching ? _stopSearch() : _startSearch();
              },
            ),
          ],
        ),
        body: productProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
                ? const Center(child: Text("Produk tidak ditemukan"))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
        bottomNavigationBar: const BottomNavWidget(),
      ),
    );
  }
}
