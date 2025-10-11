import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF0A0E1A),
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
            ],
            stops: [0.0, 0.2, 0.6, 1.0],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.2,
              colors: [
                const Color(0xFF1E3A5F).withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFFB8D4E8),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            _buildIconButton(Icons.share_outlined, () {}),
                            const SizedBox(width: 12),
                            _buildIconButton(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                                HapticFeedback.lightImpact();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Product Image
                Expanded(
                  flex: 2,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2E5C8A).withOpacity(0.3),
                              const Color(0xFF1E3A5F).withOpacity(0.2),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF2E5C8A).withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF000000).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Hero(
                                tag: 'product_${widget.product['id']}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    widget.product['image'],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.product['isNew'])
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5E9FD8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF0A0E1A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Product Details
                Expanded(
                  flex: 3,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B263B).withOpacity(0.4),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          border: Border.all(
                            color: const Color(0xFF2E5C8A).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name and Rating
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.product['name'],
                                      style: GoogleFonts.playfairDisplay(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2E5C8A,
                                      ).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFF5E9FD8),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${widget.product['rating']}',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.product['reviews']} reviews',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF8BA8C5),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Additional Images Gallery
                              if (widget.product['additionalImages'] != null &&
                                  (widget.product['additionalImages'] as List)
                                      .isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'More Views',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 80,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: widget
                                            .product['additionalImages']
                                            .length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                widget
                                                    .product['additionalImages'][index],
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),

                              // Price
                              Text(
                                '\$${widget.product['price'].toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF5E9FD8),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Description
                              Text(
                                'Description',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFB8D4E8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.product['description'],
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF8BA8C5),
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Color Selection
                              Text(
                                'Color',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFB8D4E8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(
                                  widget.product['colors'].length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColorIndex = index;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedColorIndex == index
                                            ? const Color(
                                                0xFF5E9FD8,
                                              ).withOpacity(0.2)
                                            : const Color(
                                                0xFF2E5C8A,
                                              ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _selectedColorIndex == index
                                              ? const Color(0xFF5E9FD8)
                                              : const Color(
                                                  0xFF2E5C8A,
                                                ).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        widget.product['colors'][index],
                                        style: GoogleFonts.inter(
                                          color: _selectedColorIndex == index
                                              ? const Color(0xFF5E9FD8)
                                              : const Color(0xFF8BA8C5),
                                          fontSize: 14,
                                          fontWeight:
                                              _selectedColorIndex == index
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Size Selection
                              Text(
                                'Size',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFB8D4E8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(
                                  widget.product['sizes'].length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedSizeIndex = index;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _selectedSizeIndex == index
                                            ? const Color(0xFF5E9FD8)
                                            : const Color(
                                                0xFF2E5C8A,
                                              ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _selectedSizeIndex == index
                                              ? const Color(0xFF5E9FD8)
                                              : const Color(
                                                  0xFF2E5C8A,
                                                ).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.product['sizes'][index],
                                          style: GoogleFonts.inter(
                                            color: _selectedSizeIndex == index
                                                ? const Color(0xFF0A0E1A)
                                                : const Color(0xFF8BA8C5),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Quantity
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quantity',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFB8D4E8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _buildQuantityButton(Icons.remove, () {
                                        if (_quantity > 1) {
                                          setState(() {
                                            _quantity--;
                                          });
                                          HapticFeedback.lightImpact();
                                        }
                                      }),
                                      const SizedBox(width: 16),
                                      Text(
                                        '$_quantity',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      _buildQuantityButton(Icons.add, () {
                                        setState(() {
                                          _quantity++;
                                        });
                                        HapticFeedback.lightImpact();
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Add to Cart Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF5E9FD8,
                                      ).withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added to cart: ${widget.product['name']}',
                                        ),
                                        backgroundColor: const Color(
                                          0xFF5E9FD8,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5E9FD8),
                                    foregroundColor: const Color(0xFF0A0E1A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'ADD TO CART',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1B263B).withOpacity(0.6),
        border: Border.all(
          color: const Color(0xFF2E5C8A).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Icon(icon, color: const Color(0xFFB8D4E8), size: 20),
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
        color: const Color(0xFF2E5C8A).withOpacity(0.3),
        border: Border.all(
          color: const Color(0xFF2E5C8A).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Icon(icon, color: const Color(0xFFB8D4E8), size: 18),
        ),
      ),
    );
  }
}
