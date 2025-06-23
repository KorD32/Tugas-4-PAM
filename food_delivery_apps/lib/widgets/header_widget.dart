import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider_product.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final TextEditingController _controller = TextEditingController();

  void _onSubmit(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      Provider.of<SearchProductProvider>(context, listen: false)
          .updateSearch(trimmed);

      _controller.clear();
      Navigator.pushNamed(context, '/list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF9038FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF9038FF), size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Temukan makanan favoritmu',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.wallet, color: Color(0xFF9038FF), size: 18),
                    SizedBox(width: 5),
                    Text(
                      'Rp 50.000',
                      style: TextStyle(
                        color: Color(0xFF9038FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onSubmitted: _onSubmit,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Cari makanan atau resto...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              contentPadding: EdgeInsets.all(0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          )
        ],
      ),
    );
  }
}
