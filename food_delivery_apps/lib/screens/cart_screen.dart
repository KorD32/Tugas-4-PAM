import 'package:flutter/material.dart';
import 'package:foodexpress/screens/checkout_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  void dispose() {
    super.dispose();
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
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CartProvider>().loadCart();
            },
            tooltip: 'Refresh cart',
          ),
        ],
      ),
      body: cartProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? RefreshIndicator(
                  onRefresh: () => context.read<CartProvider>().loadCart(),
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Cart masih kosong', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            SizedBox(height: 8),
                            Text('Pull to refresh', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context.read<CartProvider>().loadCart(),
                        child: ListView.separated(
                          itemCount: cartItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final productId = cartItems.keys.elementAt(i);
                          final item = cartItems[productId]!;
                          
                          
                          final quantityValue = item['quantity'];
                          int quantity = 0;
                          if (quantityValue is int) {
                            quantity = quantityValue;
                          } else if (quantityValue is String) {
                            quantity = int.tryParse(quantityValue) ?? 0;
                          }
                          
                          
                          final finalPriceValue = item['finalPrice'];
                          int finalPrice = 0;
                          if (finalPriceValue is int) {
                            finalPrice = finalPriceValue;
                          } else if (finalPriceValue is String) {
                            finalPrice = int.tryParse(finalPriceValue) ?? 0;
                          }
                          
                          final priceValue = item['price'];
                          int price = 0;
                          if (priceValue is int) {
                            price = priceValue;
                          } else if (priceValue is String) {
                            price = int.tryParse(priceValue) ?? 0;
                          }

                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: cartProvider.selectedItems[productId] ?? false,
                                  onChanged: (_) => cartProvider.toggleSelection(productId),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['imageUrl']?.toString() ?? '',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              item['name']?.toString() ?? 'Unknown Product',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Jumlah: $quantity"),
                                Text(
                                  formatrupiah.format(finalPrice),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (item['isPromos'] == true)
                                  Text(
                                    'Original: ${formatrupiah.format(price)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    cartProvider.decrementQuantity(productId);
                                  },
                                  tooltip: 'Kurangi quantity',
                                ),
                                Text('$quantity',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    cartProvider.incrementQuantity(productId);
                                  },
                                  tooltip: 'Tambah quantity',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    cartProvider.removeProductFromCart(productId);
                                  },
                                  tooltip: 'Hapus dari cart',
                                ),
                              ],
                            ),
                          );
                        },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade100, blurRadius: 8)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(formatrupiah.format(total),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9038FF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: selectedItems.isNotEmpty
                                ? () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CheckoutScreen(
                                          selectedItems: selectedItems,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      
                                      
                                      cartProvider.refreshCart();
                                    }
                                  }
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Pilih minimal 1 produk untuk checkout'),
                                      ),
                                    );
                                  },
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
