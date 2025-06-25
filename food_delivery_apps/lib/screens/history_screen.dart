import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkout_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CheckoutProvider>().history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Checkout'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada transaksi'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  leading: Image.network(item.image, width: 50),
                  title: Text('${item.quantity} x ${item.name}'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy HH:mm').format(item.dateTime),
                  ),
                  trailing: Text(
                    'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
