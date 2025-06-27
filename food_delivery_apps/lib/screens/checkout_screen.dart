import 'package:flutter/material.dart';
import 'package:foodexpress/providers/checkout_provider.dart';
import 'package:foodexpress/models/product.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<Product, int>? cartItems; // Jika dari Cart
  final String? name;
  final String? imagePath;
  final int? quantity;
  final int? price;

  const CheckoutScreen({
    this.cartItems,
    this.name,
    this.imagePath,
    this.quantity,
    this.price,
    super.key,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'Transfer Bank';

  @override
  Widget build(BuildContext context) {
    final formatRupiah =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final bool isFromCart = widget.cartItems != null;

    final int total = isFromCart
        ? widget.cartItems!.entries
            .fold(0, (sum, entry) => sum + entry.key.finalPrice * entry.value)
        : (widget.quantity! * widget.price!);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Detail Produk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (isFromCart)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.cartItems!.length,
                  itemBuilder: (context, index) {
                    final entry = widget.cartItems!.entries.elementAt(index);
                    final product = entry.key;
                    final qty = entry.value;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(product.imageUrl,
                            width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      title: Text(product.name),
                      subtitle: Text('Jumlah: $qty'),
                      trailing:
                          Text(formatRupiah.format(product.finalPrice * qty)),
                    );
                  },
                ),
              )
            else
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.imagePath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Jumlah: ${widget.quantity}'),
                        Text(
                          'Harga: ${formatRupiah.format(widget.price)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedPayment,
              isExpanded: true,
              items: ['Transfer Bank', 'E-Wallet', 'COD']
                  .map((method) =>
                      DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPayment = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            Text('Total: ${formatRupiah.format(total)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9038FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                final provider =
                    Provider.of<CheckoutProvider>(context, listen: false);

                if (isFromCart) {
                  widget.cartItems!.forEach((product, qty) {
                    provider.checkoutItem(
                      name: product.name,
                      image: product.imageUrl,
                      quantity: qty,
                      price: product.finalPrice,
                    );
                  });
                } else {
                  provider.checkoutItem(
                    name: widget.name!,
                    image: widget.imagePath!,
                    quantity: widget.quantity!,
                    price: widget.price!,
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Pembayaran berhasil dengan $_selectedPayment'),
                  ),
                );

                Navigator.pushNamed(context, '/history');
              },
              child: const Text(
                'Konfirmasi & Bayar',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
