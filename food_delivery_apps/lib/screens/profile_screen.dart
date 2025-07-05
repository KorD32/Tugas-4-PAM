import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/checkout_provider.dart';
import '../providers/auth_provider.dart' as AppAuthProvider;
import '../widgets/bottom_nav_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userProfile = context.read<UserProfileProvider>();
    final checkoutProvider = context.read<CheckoutProvider>();
    
    if (userProfile.userProfile == null) {
      userProfile.loadUserProfile();
      userProfile.listenToProfileUpdates();
    }
    
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

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF9038FF)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF9038FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Belum diisi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value.isNotEmpty ? Colors.black87 : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: const Color(0xFF9038FF),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfile, child) {
          if (userProfile.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9038FF),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9038FF),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(64),
                        ),
                        child: const CircleAvatar(
                          radius: 56,
                          backgroundColor: Color(0xFFF5F5F5),
                          child: Icon(
                            Icons.person,
                            size: 64,
                            color: Color(0xFF9038FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userProfile.username.isNotEmpty 
                            ? userProfile.username 
                            : 'User',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '-',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Kelengkapan Profil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(userProfile.profileCompletionPercentage * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: userProfile.profileCompletionPercentage,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        title: 'Username',
                        value: userProfile.username,
                        icon: Icons.person_outline,
                      ),

                      _buildInfoCard(
                        title: 'Nama Lengkap',
                        value: userProfile.name,
                        icon: Icons.badge_outlined,
                        iconColor: Colors.blue,
                      ),

                      _buildInfoCard(
                        title: 'No Handphone',
                        value: userProfile.phone,
                        icon: Icons.phone_outlined,
                        iconColor: Colors.green,
                      ),

                      _buildInfoCard(
                        title: 'Alamat Pengiriman',
                        value: userProfile.address,
                        icon: Icons.location_on_outlined,
                        iconColor: Colors.orange,
                      ),

                      const SizedBox(height: 24),

                      
                      Text(
                        'Statistik',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Consumer<CheckoutProvider>(
                        builder: (context, checkoutProvider, child) {
                          return Row(
                            children: [
                              _buildStatCard(
                                title: 'Pesanan',
                                value: checkoutProvider.orderCount.toString(),
                                icon: Icons.shopping_bag_outlined,
                                color: const Color(0xFF9038FF),
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                title: 'Total Belanja',
                                value: _formatRupiah(checkoutProvider.getTotalSpent()),
                                icon: Icons.account_balance_wallet_outlined,
                                color: Colors.green,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () async {
                            
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Logout'),
                                content: const Text('Apakah Anda yakin ingin keluar?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              final navigator = Navigator.of(context);
                              
                              await AppAuthProvider.AuthProvider.logoutAndClearAllData(context);
                              
                              if (!mounted) return;
                              navigator.pushReplacementNamed('/login');
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
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
