import 'package:flutter/material.dart';
import 'package:foodexpress/screens/checkout_screen.dart';
import 'package:foodexpress/widgets/network_status_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../widgets/bottom_nav_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = context.read<CartProvider>();
      if (!cartProvider.isInitialized) {
        cartProvider.loadCart().then((_) {
          cartProvider.listenToCartUpdates();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cart;
    final selectedItems = cartProvider.getSelectedCartItems();
    final total = cartProvider.getTotalPrice();
    final formatrupiah =
        NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        leading: BackButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        elevation: 0,
        actions: [
          const OfflineIndicator(),
        ],
      ),
      body: cartProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Keranjang kamu masih kosong',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  itemCount: cartItems.length,
                  itemBuilder: (_, i) {
                    final productId = cartItems.keys.elementAt(i);
                    final item = cartItems[productId]!;
                    final quantity =
                        int.tryParse(item['quantity'].toString()) ?? 0;
                    final finalPrice =
                        int.tryParse(item['finalPrice'].toString()) ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Checkbox(
                                value: cartProvider.selectedItems[productId] ??
                                    false,
                                onChanged: (_) =>
                                    cartProvider.toggleSelection(productId),
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item['imageUrl']?.toString() ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'] ?? 'Produk',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          quantity == 1
                                              ? Icons.delete_outline
                                              : Icons.remove,
                                          size: 14,
                                          color: quantity == 1
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                        onPressed: () {
                                          if (quantity == 1) {
                                            cartProvider.removeProductFromCart(
                                                productId);
                                          } else {
                                            cartProvider
                                                .decrementQuantity(productId);
                                          }
                                        },
                                        style: IconButton.styleFrom(
                                          shape: const CircleBorder(),
                                          minimumSize: const Size(24, 24),
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 14),
                                        onPressed: () => cartProvider
                                            .incrementQuantity(productId),
                                        style: IconButton.styleFrom(
                                          shape: const CircleBorder(),
                                          minimumSize: const Size(24, 24),
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      Spacer(),
                                      Column(
                                        children: [
                                          if (item['isPromos'] == true)
                                            const SizedBox(width: 6),
                                          Text(
                                            formatrupiah
                                                .format(finalPrice * quantity),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: cartItems.isEmpty
          ? const BottomNavWidget()
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Belanja:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(
                        formatrupiah.format(total),
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9038FF),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9038FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: selectedItems.isNotEmpty
                        ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                    selectedItems: selectedItems),
                              ),
                            );
                            if (result == true) cartProvider.refreshCart();
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Pilih minimal 1 produk untuk checkout'),
                              ),
                            );
                          },
                    child: const Text('Checkout',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
