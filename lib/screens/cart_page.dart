import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'checkout_page.dart';

/// Shopping cart page with vintage luxury theme
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;

  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();

    // Listen to cart changes
    _cartService.addListener(_onCartChanged);

    // Load cart data
    _cartService.initialize();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(_shimmerController);
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _checkout() {
    HapticFeedback.mediumImpact();
    if (_cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your cart is empty',
            style: GoogleFonts.playfairDisplay(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFFD4AF37),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Navigate to checkout page
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CheckoutPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF141414),
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [
                const Color(0xFFD4AF37).withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Cart content
                Expanded(
                  child: _cartService.items.isEmpty
                      ? _buildEmptyCart()
                      : _buildCartList(),
                ),

                // Bottom summary and checkout button
                if (_cartService.items.isNotEmpty) _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Back button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: const Color(0xFFD4AF37).withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title with shimmer
            Expanded(
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: const [
                          Color(0xFFD4AF37),
                          Color(0xFFFFF8DC),
                          Color(0xFFD4AF37),
                        ],
                        stops: [
                          (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' CART',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        if (_cartService.items.isNotEmpty)
                          Text(
                            '${_cartService.itemCount} ${_cartService.itemCount == 1 ? 'item' : 'items'}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Clear cart button
            if (_cartService.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showClearCartDialog();
                  },
                  child: Text(
                    'CLEAR',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFFD4AF37).withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'YOUR CART IS EMPTY',
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add some luxury pieces to your collection',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    'CONTINUE SHOPPING',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: _cartService.items.length,
          itemBuilder: (context, index) {
            final item = _cartService.items[index];
            return _buildCartItem(item);
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Container(
                width: 100,
                constraints: const BoxConstraints(minHeight: 140),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
                child: Image.asset(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF2A2A2A),
                      child: Icon(
                        Icons.image_not_supported,
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name and Delete Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F0F0F),
                            border: Border.all(
                              color: const Color(0xFFFF3B30).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showRemoveItemDialog(item);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: const Color(0xFFFF3B30).withOpacity(0.8),
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Color and Size
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F0F),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.selectedColor,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFD4AF37).withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F0F),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Size: ${item.selectedSize}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFD4AF37).withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price and Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price
                        Flexible(
                          child: Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.playfairDisplay(
                              color: const Color(0xFFD4AF37),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Quantity Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityButton(Icons.remove_rounded, () {
                              HapticFeedback.lightImpact();
                              if (item.quantity > 1) {
                                _cartService.updateQuantity(
                                  item.id,
                                  item.quantity - 1,
                                );
                              } else {
                                _showRemoveItemDialog(item);
                              }
                            }),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${item.quantity}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildQuantityButton(Icons.add_rounded, () {
                              HapticFeedback.lightImpact();
                              if (item.quantity < 99) {
                                _cartService.updateQuantity(
                                  item.id,
                                  item.quantity + 1,
                                );
                              }
                            }),
                          ],
                        ),
                      ],
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

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F0F0F),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Icon(
            icon,
            color: const Color(0xFFD4AF37).withOpacity(0.8),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Summary
          _buildSummaryRow('Subtotal', _cartService.subtotal),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax (10%)', _cartService.tax),
          const SizedBox(height: 12),
          _buildSummaryRow('Shipping', _cartService.shipping),
          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFD4AF37).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Total with shimmer
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: const [
                          Color(0xFFD4AF37),
                          Color(0xFFFFF8DC),
                          Color(0xFFD4AF37),
                        ],
                        stops: [
                          (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      '\$${_cartService.total.toStringAsFixed(2)}',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Checkout Button
          InkWell(
            onTap: _checkout,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'PROCEED TO CHECKOUT',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.7),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showRemoveItemDialog(CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Text(
          'Remove Item',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${item.productName} from your cart?',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37).withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _cartService.removeItem(item.id);
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: Text(
              'REMOVE',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Text(
          'Clear Cart',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37).withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _cartService.clear();
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: Text(
              'CLEAR',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
