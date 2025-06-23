import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/horizontal_product_list.dart';
import '../widgets/product_card.dart';
import 'detail_screen.dart';
import '../widgets/bottom_nav_widget.dart';

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

    final trending = products.where((p) => p.isTrending).toList();
    final promos = products.where((p) => p.isPromos).toList();

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
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(product: p)),
                    ),
                  ),
            const SectionTitleWidget(title: "Promos"),
            provider.loading
                ? const Center(child: CircularProgressIndicator())
                : HorizontalProductList(
                    products: promos,
                    onTap: (p) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(product: p)),
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
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
