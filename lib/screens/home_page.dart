import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_details.dart';

class NordenHomePage extends StatefulWidget {
  const NordenHomePage({Key? key}) : super(key: key);

  @override
  State<NordenHomePage> createState() => _NordenHomePageState();
}

class _NordenHomePageState extends State<NordenHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 1.0;
  bool _showScrollToTop = false;

  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All',
    'Suits',
    'Blazers',
    'Dress Shirts',
    'Trousers',
    'Accessories',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Double-Breasted Blazer',
      'price': 899.99,
      'image': 'assets/images/Double-breasted_blazer.jpg',
      'category': 'Blazers',
      'rating': 4.9,
      'reviews': 156,
      'isNew': true,
      'isFeatured': true,
      'colors': ['Navy', 'Charcoal', 'Black'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Elegant double-breasted blazer with perfect tailoring',
      'additionalImages': [
        'assets/images/Double-breasted_blazer (1).jpg',
        'assets/images/Double-breasted_blazer (2).jpg',
        'assets/images/Double-breasted_blazer (3).jpg',
        'assets/images/Double-breasted_blazer (4).jpg',
        'assets/images/Double-breasted_blazer (5).jpg',
        'assets/images/Double-breasted_blazer (6).jpg',
      ],
    },
    {
      'id': 2,
      'name': 'Fitted Blazer',
      'price': 699.99,
      'image': 'assets/images/Fitted_blazer.jpg',
      'category': 'Blazers',
      'rating': 4.8,
      'reviews': 124,
      'isNew': false,
      'isFeatured': true,
      'colors': ['Charcoal', 'Navy', 'Black'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Sleek fitted blazer for modern sophistication',
      'additionalImages': [
        'assets/images/Fitted_blazer (1).jpg',
        'assets/images/Fitted_blazer (2).jpg',
        'assets/images/Fitted_blazer (3).jpg',
        'assets/images/Fitted_blazer (4).jpg',
        'assets/images/Fitted_blazer (5).jpg',
        'assets/images/Fitted_blazer (6).jpg',
      ],
    },
    {
      'id': 3,
      'name': 'Long Blazer',
      'price': 799.99,
      'image': 'assets/images/Long_blazer.jpg',
      'category': 'Blazers',
      'rating': 4.7,
      'reviews': 89,
      'isNew': true,
      'isFeatured': false,
      'colors': ['Black', 'Navy', 'Charcoal'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Sophisticated long blazer for formal occasions',
      'additionalImages': [
        'assets/images/Long_blazer (1).jpg',
        'assets/images/Long_blazer (2).jpg',
        'assets/images/Long_blazer (3).jpg',
        'assets/images/Long_blazer (4).jpg',
        'assets/images/Long_blazer (5).jpg',
        'assets/images/Long_blazer (6).jpg',
        'assets/images/Long_blazer (7).jpg',
        'assets/images/Long_blazer (8).jpg',
        'assets/images/Long_blazer (9).jpg',
      ],
    },
    {
      'id': 4,
      'name': 'Trench Coat',
      'price': 1299.99,
      'image': 'assets/images/Trench_coat.jpg',
      'category': 'Blazers',
      'rating': 4.9,
      'reviews': 203,
      'isNew': false,
      'isFeatured': true,
      'colors': ['Camel', 'Black', 'Navy'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Classic trench coat for timeless elegance',
      'additionalImages': [
        'assets/images/Trench_coat (1).jpg',
        'assets/images/Trench_coat (2).jpg',
        'assets/images/Trench_coat (3).jpg',
        'assets/images/Trench_coat (4).jpg',
      ],
    },
    {
      'id': 5,
      'name': 'Car Coat',
      'price': 1099.99,
      'image': 'assets/images/Car_coat.jpg',
      'category': 'Blazers',
      'rating': 4.9,
      'reviews': 98,
      'isNew': true,
      'isFeatured': true,
      'colors': ['Black', 'Navy', 'Charcoal'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Luxurious car coat for sophisticated layering',
      'additionalImages': [
        'assets/images/Car_coat (1).jpg',
        'assets/images/Car_coat (2).jpg',
        'assets/images/Car_coat (3).jpg',
        'assets/images/Car_coat (4).jpg',
        'assets/images/Car_coat (5).jpg',
        'assets/images/Car_coat (6).jpg',
        'assets/images/Car_coat (7).jpg',
        'assets/images/Car_coat (8).jpg',
        'assets/images/Car_coat (9).jpg',
      ],
    },
    {
      'id': 6,
      'name': 'Coat',
      'price': 999.99,
      'image': 'assets/images/Coat.jpg',
      'category': 'Blazers',
      'rating': 4.8,
      'reviews': 112,
      'isNew': false,
      'isFeatured': false,
      'colors': ['Charcoal', 'Navy', 'Black'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Premium wool coat with perfect drape',
      'additionalImages': [
        'assets/images/Coat (1).jpg',
        'assets/images/Coat (2).jpg',
        'assets/images/Coat (3).jpg',
        'assets/images/Coat (4).jpg',
        'assets/images/Coat (5).jpg',
        'assets/images/Coat (6).jpg',
        'assets/images/Coat (7).jpg',
        'assets/images/Coat (8).jpg',
        'assets/images/Coat (9).jpg',
      ],
    },
    {
      'id': 7,
      'name': 'Quilted Jacket',
      'price': 599.99,
      'image': 'assets/images/Quilted_jacket.jpg',
      'category': 'Blazers',
      'rating': 4.6,
      'reviews': 78,
      'isNew': true,
      'isFeatured': false,
      'colors': ['Black', 'Navy', 'Charcoal'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Stylish quilted jacket for modern appeal',
      'additionalImages': [
        'assets/images/Quilted_jacket (1).jpg',
        'assets/images/Quilted_jacket (2).jpg',
        'assets/images/Quilted_jacket (3).jpg',
        'assets/images/Quilted_jacket (4).jpg',
        'assets/images/Quilted_jacket (5).jpg',
        'assets/images/Quilted_jacket (6).jpg',
        'assets/images/Quilted_jacket (7).jpg',
        'assets/images/Quilted_jacket (8).jpg',
        'assets/images/Quilted_jacket (9).jpg',
        'assets/images/Quilted_jacket (10).jpg',
        'assets/images/Quilted_jacket (11).jpg',
        'assets/images/Quilted_jacket (12).jpg',
        'assets/images/Quilted_jacket (13).jpg',
      ],
    },
    {
      'id': 8,
      'name': 'Single-Breasted Blazer',
      'price': 749.99,
      'image': 'assets/images/Single-breasted_blazer.jpg',
      'category': 'Blazers',
      'rating': 4.9,
      'reviews': 145,
      'isNew': false,
      'isFeatured': true,
      'colors': ['Navy', 'Charcoal', 'Black'],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Classic single-breasted blazer for versatile styling',
      'additionalImages': [
        'assets/images/Single-breasted_blazer (1).jpg',
        'assets/images/Single-breasted_blazer (2).jpg',
        'assets/images/Single-breasted_blazer (3).jpg',
        'assets/images/Single-breasted_blazer (4).jpg',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scrollController.addListener(_onScroll);
    _controller.forward();
  }

  void _onScroll() {
    setState(() {
      _scrollOpacity = (1 - (_scrollController.offset / 150)).clamp(0.0, 1.0);
      _showScrollToTop = _scrollController.offset > 400;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategoryIndex == 0) return _products;
    return _products
        .where(
          (product) =>
              product['category'] == _categories[_selectedCategoryIndex],
        )
        .toList();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Opacity(
                          opacity: _scrollOpacity,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFFFFFFFF),
                                              Color(0xFF5E9FD8),
                                            ],
                                          ).createShader(bounds),
                                      child: Text(
                                        'NORDEN',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                          letterSpacing: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Luxury Collection 2025',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF8BA8C5),
                                        letterSpacing: 2.5,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildIconButton(Icons.search, () {
                                      _showSearchBottomSheet();
                                    }),
                                    const SizedBox(width: 12),
                                    _buildIconButton(
                                      Icons.shopping_bag_outlined,
                                      () {},
                                      badge: 3,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Categories
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final isSelected =
                                  index == _selectedCategoryIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(right: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryIndex = index;
                                      });
                                      HapticFeedback.mediumImpact();
                                    },
                                    borderRadius: BorderRadius.circular(28),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  const Color(
                                                    0xFF5E9FD8,
                                                  ).withOpacity(0.4),
                                                  const Color(
                                                    0xFF2E5C8A,
                                                  ).withOpacity(0.3),
                                                ],
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(
                                                  0xFF5E9FD8,
                                                ).withOpacity(0.6)
                                              : const Color(
                                                  0xFF2E5C8A,
                                                ).withOpacity(0.3),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF5E9FD8,
                                                  ).withOpacity(0.2),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _categories[index],
                                          style: GoogleFonts.inter(
                                            color: isSelected
                                                ? const Color(0xFF5E9FD8)
                                                : const Color(0xFF8BA8C5),
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Product Count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_filteredProducts.length} Products',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8BA8C5),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _buildSortButton(),
                          ],
                        ),
                      ),
                    ),

                    // Products Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 20,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = _filteredProducts[index];
                          return SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildProductCard(product, index),
                            ),
                          );
                        }, childCount: _filteredProducts.length),
                      ),
                    ),

                    // Bottom Spacing
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),
            ),
          ),

          // Scroll to Top Button
          if (_showScrollToTop)
            Positioned(
              bottom: 32,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showScrollToTop ? 1.0 : 0.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _scrollToTop,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF5E9FD8), Color(0xFF2E5C8A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x665E9FD8),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {int? badge}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1B263B).withOpacity(0.6),
        border: Border.all(
          color: const Color(0xFF2E5C8A).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(24),
              child: Center(
                child: Icon(icon, color: Color(0xFFB8D4E8), size: 22),
              ),
            ),
          ),
          if (badge != null && badge > 0)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E9FD8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0A0E1A), width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    badge.toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showSortBottomSheet();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E5C8A).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.tune, color: Color(0xFF8BA8C5), size: 18),
            const SizedBox(width: 6),
            Text(
              'Sort',
              style: GoogleFonts.inter(
                color: const Color(0xFF8BA8C5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductDetailsPage(product: product),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.1),
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
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF1B263B).withOpacity(0.4),
            border: Border.all(
              color: const Color(0xFF2E5C8A).withOpacity(0.2),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2E5C8A).withOpacity(0.3),
                        const Color(0xFF1E3A5F).withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Hero(
                          tag: 'product_${product['id']}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: Image.asset(
                              product['image'],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      if (product['isNew'])
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5E9FD8), Color(0xFF4A8DC7)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF5E9FD8,
                                  ).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'NEW',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1B263B).withOpacity(0.8),
                            border: Border.all(
                              color: const Color(0xFF2E5C8A).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: const Icon(
                                Icons.favorite_border,
                                color: Color(0xFFB8D4E8),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFB800),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product['rating']}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8BA8C5),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product['reviews']})',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8BA8C5).withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product['price'].toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF5E9FD8),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF5E9FD8).withOpacity(0.3),
                                  const Color(0xFF2E5C8A).withOpacity(0.2),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFF5E9FD8).withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: const Icon(
                                  Icons.add,
                                  color: Color(0xFF5E9FD8),
                                  size: 18,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF8BA8C5).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sort By',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption('Price: Low to High'),
            _buildSortOption('Price: High to Low'),
            _buildSortOption('Highest Rated'),
            _buildSortOption('Most Popular'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: const Color(0xFF8BA8C5),
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.check_circle_outline,
              color: const Color(0xFF2E5C8A).withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1B263B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF8BA8C5).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF8BA8C5).withOpacity(0.5),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF5E9FD8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D1B2A).withOpacity(0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFF2E5C8A).withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFF2E5C8A).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF5E9FD8),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
