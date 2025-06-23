import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/horizontal_product_list.dart';
import '../widgets/product_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.products;

    // Dummy split products jadi trending/promos
    final trending = products.length > 4 ? products.sublist(0, 4) : products;
    final promos = products.length > 8 ? products.sublist(4, 8) : products;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: ListView(
          children: [
            const HeaderWidget(),
            const CategoryWidget(),
            const SectionTitleWidget(title: "Trending"),
            provider.loading
              ? const Center(child: CircularProgressIndicator())
              : HorizontalProductList(
                  products: trending,
                  onTap: (p) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(product: p)),
                  ),
                ),
            const SectionTitleWidget(title: "Promos"),
            provider.loading
              ? const Center(child: CircularProgressIndicator())
              : HorizontalProductList(
                  products: promos,
                  onTap: (p) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(product: p)),
                  ),
                ),
            const SizedBox(height: 24),
            const SectionTitleWidget(title: "Semua Menu"),
            provider.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: products[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(product: products[i]),
                        ),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF9038FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Basket'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        onTap: (idx) {
          if (idx == 2) Navigator.pushNamed(context, '/cart');
          if (idx == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}
