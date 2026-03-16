import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/season_provider.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = SeasonScope.of(context).tokens;
    final navBg = t.bg.withOpacity(0.97);
    final selectedColor = t.gold;

    final items = [
      _NavItem(icon: Icons.home_rounded,           label: 'Home'),
      _NavItem(icon: Icons.favorite_border_rounded, label: 'Wishlist'),
      _NavItem(icon: Icons.shopping_cart_outlined,  label: 'Cart'),
      _NavItem(icon: Icons.person_outline_rounded,  label: 'Profile'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        color: Colors.transparent,
        // padding bottom is handled by SafeArea
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: t.gold.withOpacity(0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];

              // ⚠️ Keep the base icon in a separate final to avoid
              // self-referencing closure (Stack Overflow).
              final Widget baseIcon = Icon(
                item.icon,
                color: isSelected ? t.bg : Colors.white60,
                size: isSelected ? 28 : 26,
              );

              Widget iconWidget = baseIcon;

              // Add badges for Wishlist (index 1) and Cart (index 2)
              if (index == 1) {
                iconWidget = Consumer<WishlistService>(
                  builder: (context, wishlist, child) {
                    final count = wishlist.getWishlistCountSync();
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        baseIcon, // use baseIcon, NOT iconWidget
                        if (count > 0)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: navBg, width: 1.5),
                              ),
                              child: Text(
                                count > 9 ? '9+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              } else if (index == 2) {
                iconWidget = Consumer<CartService>(
                  builder: (context, cart, child) {
                    final count = cart.itemCount;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        baseIcon, // use baseIcon, NOT iconWidget
                        if (count > 0)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: navBg, width: 1.5),
                              ),
                              child: Text(
                                count > 9 ? '9+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: iconWidget,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
