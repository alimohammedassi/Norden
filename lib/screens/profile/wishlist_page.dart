import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/wishlist_service.dart';
import '../../models/wishlist_item.dart';
import '../product_details.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService _wishlistService = WishlistService();

  @override
  void initState() {
    super.initState();
    _wishlistService.loadWishlist();
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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: StreamBuilder<List<WishlistItem>>(
                  stream: _wishlistService.getWishlistProductsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD4AF37),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      print('Wishlist Error: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading wishlist',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFD4AF37),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFFD4AF37).withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final products = snapshot.data ?? [];
                    print('Wishlist products count: ${products.length}');
                    if (products.isNotEmpty) {
                      print('First product: ${products[0]}');
                    }

                    if (products.isEmpty) {
                      return _buildEmptyState();
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(products[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFD4AF37),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'WISHLIST',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: const Color(0xFFD4AF37).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Wishlist is Empty',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD4AF37).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love for later',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFD4AF37).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(WishlistItem product) {
    final images = [product.imageUrl]; // Convert single image URL to list
    final imageUrl = images != null && images.isNotEmpty ? images[0] : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              product: {
                'id': product.productId,
                'name': product.productName,
                'price': product.price,
                'images': [product.imageUrl],
                'category': product.category,
                'colors': ['Black', 'White'], // Default colors
                'sizes': ['S', 'M', 'L'], // Default sizes
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: imageUrl.isNotEmpty
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF1A1A1A),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFFD4AF37),
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFF1A1A1A),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFFD4AF37),
                              size: 40,
                            ),
                          ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      _wishlistService.removeFromWishlist(product.productId);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFFD4AF37),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${product.price}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                      ),
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
}
