import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HorizontalProductList extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onTap;

  const HorizontalProductList({required this.products, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => SizedBox(
          width: 180,
          child: ProductCard(
            product: products[i],
            onTap: () => onTap(products[i]),
          ),
        ),
      ),
    );
  }
}
