import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isHorizontal;
  final double? cardHeight;
  final double? imageHeight;
  final bool showDiscountOverlay;

  const ProductCard({
    required this.product,
    required this.onTap,
    this.isHorizontal = false,
    this.cardHeight,
    this.imageHeight,
    this.showDiscountOverlay = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final originalPrice = product.price;
    final finalPrice = product.finalPrice;
    final hasPromo = product.isPromos;

    if (isHorizontal) {
      return SizedBox(
        height: cardHeight ?? 260,
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          height: imageHeight ?? 100,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: imageHeight ?? 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  hasPromo
                      ? Row(
                          children: [
                            Text(
                              formatRupiah.format(originalPrice),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatRupiah.format(finalPrice),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          formatRupiah.format(finalPrice),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text('${product.rating ?? '-'}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Text(
                    product.category,
                    style: const TextStyle(fontSize: 11, color: Colors.purple),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.storefront,
                          size: 13, color: Colors.deepPurple),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          product.shopName ?? '-',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
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
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  height: 72,
                  width: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image,
                        size: 28, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(product.shopName ?? '-',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 121, 121, 121))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${product.rating ?? '-'}',
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 12),
                        Text(product.category,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.purple)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      hasPromo
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatRupiah.format(originalPrice),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatRupiah.format(finalPrice),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              formatRupiah.format(finalPrice),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.grey),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
