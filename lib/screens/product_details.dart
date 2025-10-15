import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;

  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isAddingToCart = false;

  final WishlistService _wishlistService = WishlistService();

  @override
  void initState() {
    super.initState();

    // Check if product is in wishlist
    _loadWishlistState();
    _wishlistService.addListener(_onWishlistChanged);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

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

    _controller.forward();
  }

  @override
  void dispose() {
    _wishlistService.removeListener(_onWishlistChanged);
    _controller.dispose();
    _shimmerController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _loadWishlistState() {
    final productId = widget.product['id']?.toString();
    if (productId != null) {
      setState(() {
        _isFavorite = _wishlistService.isInWishlist(productId);
      });
    }
  }

  void _onWishlistChanged() {
    if (mounted) {
      _loadWishlistState();
    }
  }

  Future<void> _toggleWishlist() async {
    final productId = widget.product['id']?.toString();
    if (productId == null) return;

    HapticFeedback.mediumImpact();

    if (_isFavorite) {
      await _wishlistService.removeFromWishlist(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed from wishlist',
              style: GoogleFonts.inter(color: Colors.black),
            ),
            backgroundColor: const Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      await _wishlistService.addToWishlist(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.black, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Added to wishlist',
                  style: GoogleFonts.inter(color: Colors.black),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    HapticFeedback.mediumImpact();

    await _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _scaleController.reverse();

    // Add to cart service
    final cartService = CartService();
    cartService.addItem(
      product: widget.product,
      quantity: _quantity,
      selectedColor: widget.product['colors'][_selectedColorIndex],
      selectedSize: widget.product['sizes'][_selectedSizeIndex],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Added ${widget.product['name']} to cart',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD4AF37),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _isAddingToCart = false);
    }
  }

  /// Helper to display product image from network or assets
  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image from Firebase Storage
      return Image.network(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF2A2A2A),
            child: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFD4AF37),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF2A2A2A),
            child: Icon(
              Icons.image_not_supported,
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              size: 60,
            ),
          );
        },
      );
    } else {
      // Local asset image
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF2A2A2A),
            child: Icon(
              Icons.image_not_supported,
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              size: 60,
            ),
          );
        },
      );
    }
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
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header
                    _buildHeader(),

                    // Product Image with Page Indicator
                    Expanded(flex: 2, child: _buildImageSection()),

                    const SizedBox(height: 16),

                    // Product Details
                    Expanded(flex: 3, child: _buildDetailsSection()),
                  ],
                ),

                // Animated favorite burst effect
                if (_isFavorite)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: HeartBurstPainter(animation: _controller),
                      ),
                    ),
                  ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconButton(
              Icons.arrow_back_ios,
              () => Navigator.pop(context),
            ),
            Row(
              children: [
                _buildIconButton(Icons.share_outlined, () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Share functionality',
                        style: GoogleFonts.inter(),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _buildIconButton(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  _toggleWishlist,
                  isActive: _isFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final images = [
      widget.product['image'],
      if (widget.product['additionalImages'] != null)
        ...(widget.product['additionalImages'] as List),
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _selectedImageIndex = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Hero(
                            tag: 'product_${widget.product['id']}_$index',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: _buildProductImage(images[index]),
                            ),
                          ),
                        ),
                        if (widget.product['isNew'] && index == 0)
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFB8860B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _selectedImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _selectedImageIndex == index
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFD4AF37).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Product Name and Rating
                _buildProductHeader(),
                const SizedBox(height: 24),

                // Price with shimmer effect
                _buildPriceSection(),
                const SizedBox(height: 24),

                // Description
                _buildSection(
                  'Description',
                  Text(
                    widget.product['description'],
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Color Selection
                _buildSection('Color', _buildColorSelection()),
                const SizedBox(height: 24),

                // Size Selection
                _buildSection('Size', _buildSizeSelection()),
                const SizedBox(height: 24),

                // Quantity
                _buildQuantitySection(),
                const SizedBox(height: 32),

                // Add to Cart Button
                _buildAddToCartButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product['name'],
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFD4AF37),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.product['rating']}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.product['reviews']} reviews)',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37).withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFD4AF37),
                Color(0xFFFFD700),
                Color(0xFFD4AF37),
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: Text(
            '\$${widget.product['price'].toStringAsFixed(2)}',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD4AF37),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildColorSelection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        widget.product['colors'].length,
        (index) => GestureDetector(
          onTap: () {
            setState(() => _selectedColorIndex = index);
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: _selectedColorIndex == index
                  ? const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                    )
                  : null,
              color: _selectedColorIndex != index
                  ? const Color(0xFF1A1A1A)
                  : null,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _selectedColorIndex == index
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFD4AF37).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: _selectedColorIndex == index
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              widget.product['colors'][index],
              style: GoogleFonts.inter(
                color: _selectedColorIndex == index
                    ? Colors.black
                    : const Color(0xFFD4AF37).withOpacity(0.7),
                fontSize: 14,
                fontWeight: _selectedColorIndex == index
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        widget.product['sizes'].length,
        (index) => GestureDetector(
          onTap: () {
            setState(() => _selectedSizeIndex = index);
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: _selectedSizeIndex == index
                  ? const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                    )
                  : null,
              color: _selectedSizeIndex != index
                  ? const Color(0xFF1A1A1A)
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedSizeIndex == index
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFD4AF37).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: _selectedSizeIndex == index
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.product['sizes'][index],
                style: GoogleFonts.inter(
                  color: _selectedSizeIndex == index
                      ? Colors.black
                      : const Color(0xFFD4AF37).withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantity',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFD4AF37),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              _buildQuantityButton(Icons.remove_rounded, () {
                if (_quantity > 1) {
                  setState(() => _quantity--);
                  HapticFeedback.lightImpact();
                }
              }),
              const SizedBox(width: 20),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildQuantityButton(Icons.add_rounded, () {
                if (_quantity < 99) {
                  setState(() => _quantity++);
                  HapticFeedback.lightImpact();
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_scaleController.value * 0.05),
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
            child: ElevatedButton(
              onPressed: _isAddingToCart ? null : _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isAddingToCart
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'ADD TO CART',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
              )
            : null,
        color: !isActive ? const Color(0xFF1A1A1A) : null,
        border: Border.all(
          color: isActive
              ? const Color(0xFFD4AF37)
              : const Color(0xFFD4AF37).withOpacity(0.2),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Icon(
            icon,
            color: isActive
                ? Colors.black
                : const Color(0xFFD4AF37).withOpacity(0.8),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            icon,
            color: const Color(0xFFD4AF37).withOpacity(0.8),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class HeartBurstPainter extends CustomPainter {
  final Animation<double> animation;

  HeartBurstPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value < 0.1 || animation.value > 0.5) return;

    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6 - animation.value)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.85, size.height * 0.15);
    final radius = 30.0 * animation.value * 5;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 4.0, paint);
    }
  }

  @override
  bool shouldRepaint(HeartBurstPainter oldDelegate) => true;
}
