import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Cart masih kosong'))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (_, i) {
                Product item = cart[i];
                return ListTile(
                  leading: Image.network(item.image, width: 48, height: 48),
                  title: Text(item.title),
                  subtitle: Text('Rp ${item.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => context.read<CartProvider>().removeFromCart(item),
                  ),
                );
              },
            ),
    );
  }
}
