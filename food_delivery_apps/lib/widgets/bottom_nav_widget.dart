import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});


  int _getSelectedIndex(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    switch (route) {
      case '/history':
        return 1;
      case '/cart':
        return 2;
      case '/profile':
        return 3;
      case '/':
      case '/home':
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    final routes = ['/home', '/history', '/cart', '/profile'];
    final selectedRoute = routes[index];

    if (ModalRoute.of(context)?.settings.name != selectedRoute) {
      Navigator.pushReplacementNamed(context, selectedRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getSelectedIndex(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF9038FF),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket), label: 'Basket'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'Account'),
      ],
      onTap: (index) => _onTap(context, index),
    );
  }
}
