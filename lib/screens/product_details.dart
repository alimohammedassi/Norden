import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:math' as math;
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../services/review_service.dart';
import '../models/review.dart';
import 'reviews_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isAddingToCart = false;
  ProductRating? _productRating;

  final WishlistService _wishlistService = WishlistService();
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();

    // Check if product is in wishlist
    _loadWishlistState();
    _wishlistService.addListener(_onWishlistChanged);

    // Request location permission
    _loadProductRating();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

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

    _controller.forward();
  }

  @override
  void dispose() {
    _wishlistService.removeListener(_onWishlistChanged);

    // Stop and dispose animation controllers
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();

    if (_scaleController.isAnimating) {
      _scaleController.stop();
    }
    _scaleController.dispose();

    super.dispose();
  }

  void _loadWishlistState() {
    final productId = widget.product['id']?.toString();
    if (productId != null) {
      setState(() {
        _isFavorite = _wishlistService.isInWishlistSync(productId);
      });
    }
  }

  void _onWishlistChanged() {
    if (mounted) {
      _loadWishlistState();
    }
  }

  Future<void> _loadProductRating() async {
    try {
      final rating = await _reviewService.getProductRating(
        widget.product['id'],
      );
      if (mounted) {
        setState(() {
          _productRating = rating;
        });
      }
    } catch (e) {
      print('Error loading product rating: $e');
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
    if (!mounted) return;

    setState(() => _isAddingToCart = true);
    HapticFeedback.mediumImpact();

    if (mounted) {
      await _scaleController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await _scaleController.reverse();
      }
    }

    // Add to cart service
    final cartService = CartService();
    cartService.addItem(
      productId: (widget.product['id'] ?? '').toString(),
      quantity: _quantity,
      selectedColor:
          ((widget.product['colors'] as List? ?? const <dynamic>[]).elementAt(
            _selectedColorIndex,
          )).toString(),
      selectedSize:
          ((widget.product['sizes'] as List? ?? const <dynamic>[]).elementAt(
            _selectedSizeIndex,
          )).toString(),
      productName: (widget.product['name'] ?? 'Product').toString(),
      price: _parsePrice(widget.product['price']),
      imageUrl:
          (widget.product['image'] ??
                  (widget.product['images'] is List
                      ? (widget.product['images'] as List).firstOrNull
                      : ''))
              .toString(),
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
                  'Added ${(widget.product['name'] ?? 'Product').toString()} to cart',
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
      // Network image from Firebase Storage - optimized for model display
      return Image.network(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF0A0A0A), const Color(0xFF1A1A1A)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFFD4AF37),
                    strokeWidth: 3,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF0A0A0A), const Color(0xFF1A1A1A)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Image not available',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37).withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Local asset image - optimized for model display
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF0A0A0A), const Color(0xFF1A1A1A)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Image not available',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37).withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
        color: const Color(0xFF0A0A0A),
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
          child: Stack(
            children: [
              // Full-screen product image with swipe
              _buildFullScreenImageSection(),

              // Transparent header overlay
              _buildHeader(),

              // Wishlist button - positioned better for model visibility
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                right: 20,
                child: GestureDetector(
                  onTap: _toggleWishlist,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.7),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFFD4AF37),
                      size: 26,
                    ),
                  ),
                ),
              ),

              // Image indicators - positioned better
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45 + 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [..._buildImageIndicators()],
                ),
              ),

              // Product Details (bottom sheet)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildDetailsSection(),
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
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
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
        ),
      ),
    );
  }

  Widget _buildFullScreenImageSection() {
    // Normalize images from either 'images' list or legacy 'image'/'additionalImages'
    final List<String> images = <String>[
      if (widget.product['image'] != null) widget.product['image'].toString(),
      if (widget.product['additionalImages'] is List)
        ...((widget.product['additionalImages'] as List).map(
          (e) => e.toString(),
        )),
    ];
    if (widget.product['images'] is List) {
      images.addAll(
        (widget.product['images'] as List).map((e) => e.toString()),
      );
    }
    if (images.isEmpty) {
      images.add('');
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() => _selectedImageIndex = index);
            HapticFeedback.selectionClick();
          },
          itemBuilder: (context, index) {
            return Stack(
              children: [
                // Full-screen image with enhanced display for models
                Positioned.fill(
                  child: Hero(
                    tag: 'product_${widget.product['id']}_$index',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: _buildProductImage(images[index]),
                      ),
                    ),
                  ),
                ),
                // NEW badge overlay
                if ((widget.product['isNew'] == true) && index == 0)
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
                          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
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
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildImageIndicators() {
    final List<String> images = <String>[
      if (widget.product['image'] != null) widget.product['image'].toString(),
      if (widget.product['additionalImages'] is List)
        ...((widget.product['additionalImages'] as List).map(
          (e) => e.toString(),
        )),
    ];
    if (widget.product['images'] is List) {
      images.addAll(
        (widget.product['images'] as List).map((e) => e.toString()),
      );
    }
    if (images.isEmpty) {
      images.add('');
    }

    return List.generate(
      images.length,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: _selectedImageIndex == index ? 32 : 10,
        height: 10,
        decoration: BoxDecoration(
          color: _selectedImageIndex == index
              ? const Color(0xFFD4AF37)
              : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(5),
          border: _selectedImageIndex == index
              ? null
              : Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
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
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 16),

                // Product Name and Rating
                _buildProductHeader(),
                const SizedBox(height: 16),

                // Price pill aligned to right
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '\$${_formatPrice(widget.product['price'])}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD4AF37),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description - shorter version
                _buildCompactSection(
                  'Description',
                  Text(
                    (widget.product['description'] ?? '').toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),

                // Color Selection
                _buildCompactSection('Color', _buildColorSelection()),
                const SizedBox(height: 16),

                // Size Selection
                _buildCompactSection('Size', _buildSizeSelection()),
                const SizedBox(height: 16),

                // Quantity
                _buildQuantitySection(),
                const SizedBox(height: 20),

                // Add to Cart Button
                _buildAddToCartButton(),
                const SizedBox(height: 12),
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
                (widget.product['name'] ?? 'Product').toString(),
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewsPage(
                        productId: widget.product['id'].toString(),
                        productName: widget.product['name'].toString(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: const Color(0xFFD4AF37),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _productRating?.averageRating.toStringAsFixed(1) ??
                            (widget.product['rating'] ?? '4.8').toString(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_productRating?.totalReviews ?? (widget.product['reviews'] ?? 0)} reviews)',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4AF37).withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFFD4AF37),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildColorSelection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        (widget.product['colors'] as List? ?? const <dynamic>[]).length,
        (index) => GestureDetector(
          onTap: () {
            setState(() => _selectedColorIndex = index);
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              ((widget.product['colors'] as List? ?? const <dynamic>[])[index])
                  .toString(),
              style: GoogleFonts.inter(
                color: _selectedColorIndex == index
                    ? Colors.black
                    : const Color(0xFFD4AF37).withOpacity(0.7),
                fontSize: 13,
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

  String _formatPrice(dynamic price) {
    try {
      if (price is num) return price.toStringAsFixed(2);
      if (price is String) return double.parse(price).toStringAsFixed(2);
    } catch (_) {}
    return '0.00';
  }

  double _parsePrice(dynamic price) {
    try {
      if (price is num) return price.toDouble();
      if (price is String) return double.parse(price);
    } catch (_) {}
    return 0.0;
  }

  Widget _buildSizeSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        (widget.product['sizes'] as List? ?? const <dynamic>[]).length,
        (index) => GestureDetector(
          onTap: () {
            setState(() => _selectedSizeIndex = index);
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            height: 45,
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
                ((widget.product['sizes'] as List? ?? const <dynamic>[])[index])
                    .toString(),
                style: GoogleFonts.inter(
                  color: _selectedSizeIndex == index
                      ? Colors.black
                      : const Color(0xFFD4AF37).withOpacity(0.7),
                  fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
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
            style: GoogleFonts.inter(
              color: const Color(0xFFD4AF37),
              fontSize: 15,
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
              const SizedBox(width: 16),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
        if (!mounted) return const SizedBox.shrink();
        return Transform.scale(
          scale: 1.0 - (_scaleController.value * 0.05),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SlideAction(
                  height: 60,
                  borderRadius: 30,
                  elevation: 0,
                  innerColor: const Color(0xFF1A1A1A),
                  outerColor: const Color(0xFF0A0A0A),
                  sliderButtonIconPadding: 0,
                  sliderButtonIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAddingToCart
                          ? const Color(0xFFD4AF37).withOpacity(0.3)
                          : Colors.transparent,
                    ),
                    child: _isAddingToCart
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFD4AF37),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.shopping_cart_outlined,
                            color: Color(0xFFD4AF37),
                            size: 30,
                          ),
                  ),
                  text: _isAddingToCart
                      ? 'Adding to Cart...'
                      : 'Swipe to Add to Cart',
                  textStyle: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  onSubmit: _isAddingToCart ? null : _addToCart,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Swipe right to add item',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
              )
            : null,
        color: !isActive ? Colors.black.withOpacity(0.8) : null,
        border: Border.all(
          color: isActive
              ? const Color(0xFFD4AF37)
              : const Color(0xFFD4AF37).withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
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
          borderRadius: BorderRadius.circular(18),
          child: Icon(
            icon,
            color: const Color(0xFFD4AF37).withOpacity(0.8),
            size: 18,
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
