import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/checkout_screen.dart';

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
    final formatRupiah =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          product.imageUrl,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          product.isPromos
                              ? Row(
                                  children: [
                                    Text(
                                      formatRupiah.format(product.price),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      formatRupiah.format(product.finalPrice),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  formatRupiah.format(product.price),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              Text(
                                '${product.rating ?? '-'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
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
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (quantity > 1) {
                                setState(() => quantity--);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Color(0xFF9038FF), width: 1.4),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Color(0xFF9038FF),
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              setState(() => quantity++);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Color(0xFF9038FF), width: 1.4),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF9038FF),
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Color(0xFF9038FF),
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Tambah ke Cart',
                                style: TextStyle(color: Color(0xFF9038FF)),
                              ),
                              onPressed: () {
                                for (int i = 0; i < quantity; i++) {
                                  context
                                      .read<CartProvider>()
                                      .addToCart(product);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product.name} x$quantity ditambahkan ke cart!'),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9038FF),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: quantity > 0
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CheckoutScreen(
                                            name: product.name,
                                            imagePath: product.imageUrl,
                                            quantity: quantity,
                                            price: product.finalPrice,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text(
                                'Checkout',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
