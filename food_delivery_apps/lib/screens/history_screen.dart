import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/checkout_provider.dart';
import '../widgets/bottom_nav_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final checkoutProvider = context.read<CheckoutProvider>();
    if (checkoutProvider.orderHistory.isEmpty) {
      checkoutProvider.listenToOrderHistory();
    }
    
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();
    final orderHistory = checkoutProvider.orderHistory;

    final formatRupiah = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : orderHistory.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada transaksi',
                    style: TextStyle(fontSize: 16),
                  ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                final order = orderHistory[index];
                
                List<Map<String, dynamic>> items = [];
                final itemsData = order['items'];
                if (itemsData is List) {
                  for (var item in itemsData) {
                    if (item is Map) {
                      items.add(Map<String, dynamic>.from(item.cast<String, dynamic>()));
                    }
                  }
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order['id']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(order['createdAt']),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Customer: ${order['customerName']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Payment: ${order['paymentMethod']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      
                      ...items.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item['imageUrl'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? 'Unknown Product',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qty: ${item['quantity']} x ${formatRupiah.format(item['finalPrice'] ?? item['price'] ?? 0)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatRupiah.format((item['finalPrice'] ?? item['price'] ?? 0) * (item['quantity'] ?? 1)),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                      
                      const Divider(),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatRupiah.format(order['totalAmount'] ?? 0),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
