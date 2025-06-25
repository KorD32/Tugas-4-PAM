import 'package:flutter/material.dart';
import 'package:foodexpress/providers/checkout_provider.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({required this.product, super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                product.imageUrl,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Text(product.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rp ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text('${product.rating ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(product.category)),
                if (product.shopName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Chip(label: Text(product.shopName!)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(product.description),
            const SizedBox(height: 24),

            // New: Row with Quantity, Add to Cart, Checkout
            Row(
              children: [
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.black),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.black),
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Add to Cart
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart, color: Colors.black),
                    label: const Text(
                      'Tambah ke Cart',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      for (int i = 0; i < quantity; i++) {
                        context.read<CartProvider>().addToCart(product);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${product.name} x$quantity ditambahkan ke cart!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Checkout Now
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payments_outlined,
                        color: Colors.black),
                    label: const Text(
                      'Checkout',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      context.read<CheckoutProvider>().checkoutItem(
                            name: product.name,
                            price: product.price,
                            imagePath: product.imageUrl,
                            quantity: quantity,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${product.name} x$quantity telah di-checkout!')),
                      );
                      Navigator.pushNamed(context, '/history');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
