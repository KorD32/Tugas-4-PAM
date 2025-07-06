import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/offline_cache_service.dart';

class CacheStatusScreen extends StatefulWidget {
  const CacheStatusScreen({super.key});

  @override
  State<CacheStatusScreen> createState() => _CacheStatusScreenState();
}

class _CacheStatusScreenState extends State<CacheStatusScreen> {
  Map<String, dynamic>? _cacheInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    setState(() => _loading = true);
    try {
      final info = await OfflineCacheService.getCacheInfo();
      setState(() {
        _cacheInfo = info;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error memuat info cache: $e')),
        );
      }
    }
  }

  Future<void> _clearAllCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('hapus Semua Cache'),
        content: const Text('apakah Anda yakin ingin menghapus semua data cache? Ini akan menghapus semua konten offline'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await OfflineCacheService.clearAllCache();
        await _loadCacheInfo();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua cache berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('error menghapus cache: $e')),
          );
        }
      }
    }
  }

  Future<void> _clearExpiredCache() async {
    try {
      await OfflineCacheService.clearExpiredCache();
      await _loadCacheInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache kedaluwarsa berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menghapus cache kedaluwarsa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Cache'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCacheInfo,
            tooltip: 'Refresh info cache',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cacheInfo == null
              ? const Center(child: Text('Gagal memuat informasi cache'))
              : RefreshIndicator(
                  onRefresh: _loadCacheInfo,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _cacheInfo!['isOnline'] ? Icons.wifi : Icons.wifi_off,
                                    color: _cacheInfo!['isOnline'] ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Status Koneksi',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _cacheInfo!['isOnline'] ? 'Online' : 'Offline',
                                style: TextStyle(
                                  color: _cacheInfo!['isOnline'] ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (_cacheInfo!['lastOnlineTime'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Terakhir online: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(_cacheInfo!['lastOnlineTime']))}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.storage, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ringkasan Cache',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total item cache:'),
                                  Text(
                                    '${_cacheInfo!['cacheCount']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total ukuran:'),
                                  Text(
                                    '${_cacheInfo!['totalSizeKB']} KB',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      
                      if (_cacheInfo!['categoryCounts'] != null) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.category, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cache per Kategori',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...(_cacheInfo!['categoryCounts'] as Map<String, dynamic>)
                                    .entries
                                    .where((entry) => entry.value > 0)
                                    .map((entry) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    _getCategoryIcon(entry.key),
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(_getCategoryNameInIndonesian(entry.key)),
                                                ],
                                              ),
                                              Text(
                                                '${entry.value}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.settings, color: Colors.purple),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Manajemen Cache',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _clearExpiredCache,
                                  icon: const Icon(Icons.cleaning_services),
                                  label: const Text('Hapus Cache Kedaluwarsa'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _clearAllCache,
                                  icon: const Icon(Icons.delete_forever),
                                  label: const Text('Hapus Semua Cache'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _getCategoryNameInIndonesian(String category) {
    switch (category) {
      case 'products':
        return 'Produk';
      case 'cart':
        return 'Keranjang';
      case 'profile':
        return 'Profil';
      case 'orders':
        return 'Pesanan';
      default:
        return category.toUpperCase();
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'products':
        return Icons.restaurant_menu;
      case 'cart':
        return Icons.shopping_cart;
      case 'profile':
        return Icons.person;
      case 'orders':
        return Icons.receipt;
      default:
        return Icons.folder;
    }
  }
}
