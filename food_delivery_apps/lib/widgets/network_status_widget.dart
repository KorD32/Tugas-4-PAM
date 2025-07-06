import 'package:flutter/material.dart';
import '../services/offline_cache_service.dart';

class NetworkStatusWidget extends StatefulWidget {
  final Widget child;
  
  const NetworkStatusWidget({required this.child, super.key});

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  bool _isOnline = true;
  bool _showOfflineBanner = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      final isOnline = await OfflineCacheService.isOnline();
      if (mounted && _isOnline != isOnline) {
        setState(() {
          _isOnline = isOnline;
          _showOfflineBanner = !isOnline;
        });
        
        if (!isOnline) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() => _showOfflineBanner = false);
            }
          });
        }
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showOfflineBanner ? 30 : 0,
          child: _showOfflineBanner
              ? Container(
                  width: double.infinity,
                  color: Colors.orange.shade700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'offline mode',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showOfflineBanner = false),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OfflineCacheService.isOnline(),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (isOnline) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 6),
              Text(
                'Offline',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
