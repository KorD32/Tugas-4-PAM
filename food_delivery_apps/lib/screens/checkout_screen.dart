import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/checkout_provider.dart';
import '../providers/user_profile_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<int, Map<String, dynamic>> selectedItems;

  const CheckoutScreen({
    required this.selectedItems,
    super.key,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedPayment = 'Transfer Bank';
  bool _loading = false;

  final List<String> _paymentMethods = [
    'Transfer Bank',
    'E-Wallet',
    'Credit Card',
    'Cash on Delivery',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  void _loadUserProfile() {
    final userProfile = context.read<UserProfileProvider>();
    userProfile.loadUserProfile();
  }

  int _calculateTotal() {
    int total = 0;
    widget.selectedItems.forEach((productId, item) {
      final price = item['finalPrice'] as int;
      final quantity = item['quantity'] as int;
      total += price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: "id_ID", 
      symbol: "Rp ", 
      decimalDigits: 0
    );
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    _buildSectionTitle('Order Summary'),
                    _buildOrderSummary(formatRupiah),
                    
                    const SizedBox(height: 24),
                    
                    
                    _buildSectionTitle('Informasi Pengiriman'),
                    _buildDeliveryInfo(),
                    
                    const SizedBox(height: 24),
                    
                    
                    _buildSectionTitle('Payment Method'),
                    _buildPaymentMethods(),
                    
                    const SizedBox(height: 24),
                    
                    
                    _buildTotalSection(formatRupiah, total),
                  ],
                ),
              ),
            ),
            
            
            _buildCheckoutButton(total),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderSummary(NumberFormat formatRupiah) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: widget.selectedItems.entries.map((entry) {
            final item = entry.value;
            final quantity = item['quantity'] as int;
            final price = item['finalPrice'] as int;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['imageUrl'] as String,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${formatRupiah.format(price)} x $quantity',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiah.format(price * quantity),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfile, child) {
        
        bool isProfileComplete = userProfile.name.isNotEmpty && 
                                userProfile.phone.isNotEmpty && 
                                userProfile.address.isNotEmpty;

        if (!isProfileComplete) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Profil Tidak Lengkap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silakan lengkapi profil Anda terlebih dahulu sebelum melakukan checkout.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Lengkapi Profil', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama Lengkap', userProfile.name, Icons.person),
                const SizedBox(height: 12),
                _buildInfoRow('No Handphone', userProfile.phone, Icons.phone),
                const SizedBox(height: 12),
                _buildInfoRow('Alamat Pengiriman', userProfile.address, Icons.location_on),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Untuk mengubah informasi pengiriman, silakan edit di halaman profil.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9038FF)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _paymentMethods.map((method) {
            return RadioListTile<String>(
              title: Text(method),
              value: method,
              groupValue: _selectedPayment,
              onChanged: (value) {
                setState(() {
                  _selectedPayment = value!;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTotalSection(NumberFormat formatRupiah, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Payment:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formatRupiah.format(total),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9038FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _loading ? null : _processCheckout,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Place Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _processCheckout() async {
    final userProfile = context.read<UserProfileProvider>();
    

    if (userProfile.name.isEmpty || userProfile.phone.isEmpty || userProfile.address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan lengkapi profil Anda terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final checkoutProvider = context.read<CheckoutProvider>();
      
      final cartItems = widget.selectedItems.values.toList();
      
      final success = await checkoutProvider.createCheckout(
        customerName: userProfile.name,
        customerPhone: userProfile.phone,
        customerAddress: userProfile.address,
        paymentMethod: _selectedPayment,
        totalAmount: _calculateTotal(),
        cartItems: cartItems,
      );

      if (success && mounted) {

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Pesanan Berhasil Dibuat!'),
            content: const Text('Pesanan Anda telah dibuat dan sedang diproses.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pop(true);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat pesanan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
