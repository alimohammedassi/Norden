import 'package:flutter/material.dart';
import 'home_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../providers/season_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = SeasonScope.of(context).tokens;

    return Scaffold(
      backgroundColor: t.bg,
      // Use extendBody so the content goes behind the nav bar
      extendBody: true,
      body: _buildPage(_currentIndex),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const NordenHomePage(showNavIcons: false);
      case 1:
        return const WishlistPage(showBackButton: false);
      case 2:
        return const CartPage(showBackButton: false);
      case 3:
        return const ProfilePage(showBackButton: false);
      default:
        return const NordenHomePage(showNavIcons: false);
    }
  }
}
