import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodexpress/screens/list_product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/horizontal_product_list.dart';
import '../widgets/product_card.dart';
import '../widgets/network_status_widget.dart';
import 'detail_screen.dart';
import '../widgets/bottom_nav_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _adsController;
  int _currentAdIndex = 0;
  Timer? _adsTimer;
  final List<String> adsImages = [
    "assets/ads_1.png",
    "assets/ads_2.png",
    "assets/ads_3.png"
  ];

  @override
  void initState() {
    super.initState();
    _adsController = PageController();
    _startAdsAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty) {
        productProvider.fetchProducts();
      }

      final userProfile =
          Provider.of<UserProfileProvider>(context, listen: false);
      userProfile.loadUserProfile();
    });
  }

  void _startAdsAutoScroll() {
    _adsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_adsController.hasClients) {
        _currentAdIndex = (_currentAdIndex + 1) % adsImages.length;
        _adsController.animateToPage(
          _currentAdIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _adsController.dispose();
    _adsTimer?.cancel();
    super.dispose();
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
        child: Column(
          children: [
            const OfflineIndicator(),
            Expanded(
              child: ListView(
                children: [
                  const HeaderWidget(),
                  SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: PageView.builder(
                        controller: _adsController,
                        itemCount: adsImages.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            adsImages[index],
                            fit: BoxFit.contain,
                            width: double.infinity,
                          );
                        },
                      )),
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
                                  builder: (_) =>
                                      DetailScreen(product: products[i]),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ListProductScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9038FF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Lanjut',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
