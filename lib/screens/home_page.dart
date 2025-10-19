import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_details.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/wishlist_service.dart';
import '../models/product.dart';
import 'cart_page.dart';
import 'profile_page.dart';

/// Main StatefulWidget for the Norden luxury fashion home page
/// This widget manages the overall state and animations of the home page
class NordenHomePage extends StatefulWidget {
  const NordenHomePage({Key? key}) : super(key: key);

  @override
  State<NordenHomePage> createState() => _NordenHomePageState();
}

/// State class that handles all animations, scroll events, and UI logic
/// Uses TickerProviderStateMixin to create multiple animation controllers
class _NordenHomePageState extends State<NordenHomePage>
    with TickerProviderStateMixin {
  // ============== ANIMATION CONTROLLERS ==============
  /// Controller for main fade and slide animations
  late AnimationController _controller;

  /// Controller for shimmer effect on logo
  late AnimationController _shimmerController;

  /// Controller for pulse animation effects
  late AnimationController _pulseController;

  /// Controller for announcement carousel transitions
  late AnimationController _announcementController;

  // ============== ANIMATION OBJECTS ==============
  /// Fade animation - transitions elements from 0 to 1 opacity
  late Animation<double> _fadeAnimation;

  /// Slide animation - moves elements vertically during entrance
  late Animation<Offset> _slideAnimation;

  /// Shimmer animation - creates moving light effect on logo
  late Animation<double> _shimmerAnimation;

  // ============== SCROLL MANAGEMENT ==============
  /// ScrollController to track scroll position and listen to scroll events
  final ScrollController _scrollController = ScrollController();

  /// Tracks opacity of header based on scroll position (fades as user scrolls down)
  double _scrollOpacity = 1.0;

  /// Boolean to show/hide scroll-to-top button based on scroll distance
  bool _showScrollToTop = false;

  // ============== CAROUSEL/ANNOUNCEMENT MANAGEMENT ==============
  /// PageController for managing announcement carousel pagination
  final PageController _announcementPageController = PageController();

  /// Tracks current announcement index for page indicators
  int _currentAnnouncementIndex = 0;

  // ============== CATEGORY MANAGEMENT ==============
  /// Index of currently selected category for filtering products
  int _selectedCategoryIndex = 0;

  // ============== CONSTANTS ==============
  /// Scroll distance before header opacity reaches 0
  static const double _maxScrollForOpacity = 150.0;

  /// Scroll distance required before showing scroll-to-top button
  static const double _scrollToTopThreshold = 400.0;

  /// Duration for main page entrance animations
  static const Duration _animationDuration = Duration(milliseconds: 1400);

  /// Duration for logo shimmer animation loop
  static const Duration _shimmerDuration = Duration(milliseconds: 3000);

  /// Duration for pulse animation effects
  static const Duration _pulseDuration = Duration(milliseconds: 2000);

  // ============== SERVICES ==============
  /// Product service for Firebase operations
  final ProductService _productService = ProductService();

  /// Cart service for managing shopping cart
  final CartService _cartService = CartService();

  /// Wishlist service for managing favorites
  final WishlistService _wishlistService = WishlistService();

  // ============== DATA ==============
  /// List of announcement data shown in carousel
  /// Each announcement has title, subtitle, image, discount, etc.
  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 1,
      'title': 'SPRING COLLECTION',
      'subtitle': 'New Arrivals',
      'description': 'Discover the essence of refined elegance',
      'image': 'assets/images/Double-breasted_blazer.jpg',
      'discount': '25% OFF',
      'color': const Color(0xFFD4AF37),
    },
    {
      'id': 2,
      'title': 'LIMITED EDITION',
      'subtitle': 'Exclusive Line',
      'description': 'Handcrafted luxury for the discerning gentleman',
      'image': 'assets/images/Trench_coat.jpg',
      'discount': 'MEMBERS ONLY',
      'color': const Color(0xFFD4AF37),
    },
    {
      'id': 3,
      'title': 'BESPOKE TAILORING',
      'subtitle': 'Made to Measure',
      'description': 'Your perfect fit, crafted with precision',
      'image': 'assets/images/Car_coat.jpg',
      'discount': 'BOOK NOW',
      'color': const Color(0xFFD4AF37),
    },
  ];

  /// List of category names for filtering
  final List<String> _categories = [
    'All',
    'Suits',
    'Blazers',
    'Dress Shirts',
    'Trousers',
    'Accessories',
  ];

  /// List of all available products with details
  /// This will be populated from Firebase Firestore by the admin
  final List<Map<String, dynamic>> _products = [];

  /// Load sample products for testing
  void _loadSampleProducts() {
    final sampleProducts = Product.getSampleProducts();
    _products.clear();
    for (final product in sampleProducts) {
      _products.add(_productToMap(product));
    }
    if (mounted) {
      setState(() {});
    }
  }

  // ============== LIFECYCLE METHODS ==============

  /// initState: Called once when widget is first created
  /// Initializes all animations, listeners, and starts auto-play for announcements
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);
    _cartService.addListener(_onCartChanged);
    _wishlistService.loadWishlist();
    _controller.forward();
    _announcementController.forward();
    _startAnnouncementAutoPlay();

    // Load products from Firebase
    _loadFirebaseProducts();
    // Load sample products for testing
    _loadSampleProducts();
  }

  /// _onCartChanged: Callback when cart changes to update UI
  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// _initializeAnimations: Sets up all animation controllers and animations
  /// Creates fade, slide, and shimmer effects with different timing curves
  void _initializeAnimations() {
    // Main animation controller for entrance animations
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    // Repeating shimmer animation for logo glow effect
    _shimmerController = AnimationController(
      duration: _shimmerDuration,
      vsync: this,
    )..repeat();

    // Repeating pulse animation for subtle pulsing effects
    _pulseController = AnimationController(
      duration: _pulseDuration,
      vsync: this,
    )..repeat(reverse: true);

    // Announcement carousel transition animations
    _announcementController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade animation: opacity goes from 0 to 1 with smooth easing
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Slide animation: elements slide up from below with smoother motion
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.15, 0.95, curve: Curves.easeOutQuart),
          ),
        );

    // Shimmer animation: creates a moving light gradient effect (-2 to 2)
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(_shimmerController);

    // Set initial value to prevent animation issues
    _announcementController.value = 1.0;
  }

  /// _startAnnouncementAutoPlay: Automatically advances announcements every 10 seconds
  /// Creates a recursive delayed loop for continuous carousel cycling
  void _startAnnouncementAutoPlay() {
    _runAnnouncementLoop();
  }

  /// _runAnnouncementLoop: Async loop that continuously advances the announcement carousel
  /// Stops automatically when widget is disposed (mounted becomes false)
  Future<void> _runAnnouncementLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 10));

      if (mounted) {
        _announcementPageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      } else {
        break;
      }
    }
  }

  /// _onScroll: Callback triggered whenever user scrolls
  /// Updates header opacity and scroll-to-top button visibility
  void _onScroll() {
    setState(() {
      // Calculate opacity: fades header as user scrolls down
      _scrollOpacity = (1 - (_scrollController.offset / _maxScrollForOpacity))
          .clamp(0.0, 1.0);

      // Show scroll-to-top button when user scrolls down 400+ pixels
      _showScrollToTop = _scrollController.offset > _scrollToTopThreshold;
    });
  }

  /// dispose: Cleanup method called when widget is destroyed
  /// Disposes all animation controllers and listeners to prevent memory leaks
  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _controller.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _announcementController.dispose();
    _scrollController.dispose();
    _announcementPageController.dispose();
    super.dispose();
  }

  // ============== GETTERS ==============

  /// _filteredProducts: Returns list of products based on selected category
  /// If "All" category is selected, returns all products
  /// Otherwise filters products matching the selected category
  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategoryIndex == 0) return _products;
    return _products
        .where(
          (product) =>
              product['category'] == _categories[_selectedCategoryIndex],
        )
        .toList();
  }

  // ============== HELPER METHODS ==============

  /// Converts Product model to Map format for UI compatibility
  Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.images.isNotEmpty
          ? product.images[0]
          : 'assets/images/Double-breasted_blazer.jpg',
      'category': product.category,
      'rating': 4.8,
      'reviews': 100,
      'isNew': product.isNew,
      'isFeatured': product.isFeatured,
      'colors': product.colors,
      'sizes': product.sizes,
      'description': product.description,
      'additionalImages': product.images.length > 1
          ? product.images.sublist(1)
          : [],
    };
  }

  /// Load products from backend and update UI
  void _loadFirebaseProducts() async {
    try {
      final products = await _productService.getProducts();
      if (mounted) {
        setState(() {
          // Clear hardcoded products and replace with backend products
          _products.clear();
          if (products.isNotEmpty) {
            _products.addAll(products.map((p) => _productToMap(p)).toList());
          } else {
            // If no products from backend, load sample products as fallback
            _loadSampleProducts();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      // Keep sample products as fallback
      if (mounted) {
        setState(() {
          _loadSampleProducts();
        });
      }
    }
  }

  // ============== ACTIONS ==============

  /// _scrollToTop: Animates scroll view to top with easing
  /// Also triggers haptic feedback to indicate action
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
    HapticFeedback.mediumImpact();
  }

  /// _navigateToProductDetails: Pushes product details page with custom animation
  /// Uses page route builder for smooth fade + slide transition
  void _navigateToProductDetails(Map<String, dynamic> product) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailsPage(product: product),
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

  /// _showSortBottomSheet: Displays sort options modal
  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _VintageSortBottomSheet(
        onSortSelected: (sortType) {
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
      ),
    );
  }

  /// _showSearchBottomSheet: Displays search modal
  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VintageSearchBottomSheet(
        onSearch: (query) {
          // TODO: Implement search functionality
        },
      ),
    );
  }

  // ============== BUILD METHOD ==============

  /// Main build method: Constructs the entire page layout
  /// Uses CustomScrollView for efficient scrolling with SliverWidgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background with vintage gradient
          _buildVintageBackground(),

          // Main content wrapped in SafeArea
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header section with fade animation
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Opacity(
                      opacity: _scrollOpacity,
                      child: _buildElegantHeader(),
                    ),
                  ),
                ),

                // Announcement carousel with slide and fade animations
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAnnouncementCarousel(),
                    ),
                  ),
                ),

                // Decorative divider
                SliverToBoxAdapter(child: _buildVintageDivider()),

                // Category filter chips
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildVintageCategoryList(),
                  ),
                ),

                // Product count and filter button
                SliverToBoxAdapter(child: _buildProductCountSection()),

                // Product grid with 2 columns
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = _filteredProducts[index];
                      return _buildVintageProductCard(product, index);
                    }, childCount: _filteredProducts.length),
                  ),
                ),

                // Bottom spacing for scroll room
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),

          // Floating scroll-to-top button
          if (_showScrollToTop) _buildFloatingScrollButton(),
        ],
      ),
    );
  }

  // ============== BUILD UI METHODS ==============

  /// _buildVintageBackground: Creates dark gradient background with gold accents
  /// Uses layered containers with different opacities for depth
  Widget _buildVintageBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
      child: Stack(
        children: [
          // Subtle pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      const Color(0xFFD4AF37).withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Gold accent from top
          Container(
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
          ),
        ],
      ),
    );
  }

  /// _buildElegantHeader: Constructs top header with logo and action buttons
  Widget _buildElegantHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo section on left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildVintageLogo(), const SizedBox(height: 8)],
            ),
          ),
          // Action buttons on right (search, profile, cart)
          Row(
            children: [
              _buildVintageIconButton(
                Icons.search_rounded,
                _showSearchBottomSheet,
              ),
              const SizedBox(width: 12),
              _buildVintageIconButton(Icons.person_outline_rounded, () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ProfilePage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
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
              }),
              const SizedBox(width: 12),
              _buildVintageIconButton(Icons.shopping_bag_outlined, () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const CartPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
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
              }, badge: _cartService.itemCount),
            ],
          ),
        ],
      ),
    );
  }

  /// _buildVintageLogo: Creates animated "NORDEN" logo with shimmer effect
  /// Uses ShaderMask to apply gradient shimmer animation
  Widget _buildVintageLogo() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD4AF37),
                const Color(0xFFFFF8DC),
                const Color(0xFFD4AF37),
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
              SizedBox(height: 10),
              Text(
                'N',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 45,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 6,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        );
      },
    );
  }

  /// _buildAnnouncementCarousel: Creates PageView carousel with announcements
  /// Auto-plays and shows page indicators
  Widget _buildAnnouncementCarousel() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _announcementPageController,
              itemCount: 10000, // Large number for infinite-like scrolling
              onPageChanged: (index) {
                setState(() {
                  _currentAnnouncementIndex = index % _announcements.length;
                });
                _announcementController.forward(from: 0);
              },
              itemBuilder: (context, index) {
                final announcement =
                    _announcements[index % _announcements.length];
                return _buildAnnouncementCard(announcement);
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildPageIndicators(),
        ],
      ),
    );
  }

  /// _buildAnnouncementCard: Individual announcement card with image and text overlay
  /// Displays image with dark overlay and text content at bottom
  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1A1A), const Color(0xFF0F0F0F)],
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: announcement['color'].withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background image with dark gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Image.asset(
                  announcement['image'] ?? 'assets/images/placeholder.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: const Color(0xFF1A1A1A));
                  },
                ),
              ),
            ),
            // Text content overlay at bottom
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Discount badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: announcement['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: announcement['color'].withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      announcement['discount'],
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: announcement['color'],
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    announcement['subtitle'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFFD4AF37).withOpacity(0.8),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Main title
                  Text(
                    announcement['title'],
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    announcement['description'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// _buildPageIndicators: Creates dots showing current announcement page
  /// Animated indicators change size and color based on active page
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _announcements.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentAnnouncementIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentAnnouncementIndex == index
                ? const Color(0xFFD4AF37)
                : const Color(0xFFD4AF37).withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  /// _buildVintageDivider: Decorative divider with "COLLECTIONS" text and diamond icons
  Widget _buildVintageDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // Left gradient line
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFFD4AF37).withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          // Center text with icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.diamond_outlined,
                  size: 12,
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'COLLECTIONS',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 10,
                    color: const Color(0xFFD4AF37).withOpacity(0.7),
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.diamond_outlined,
                  size: 12,
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                ),
              ],
            ),
          ),
          // Right gradient line
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// _buildVintageCategoryList: Horizontal scrollable category filter chips
  Widget _buildVintageCategoryList() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return _VintageCategoryChip(
            label: _categories[index],
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              HapticFeedback.selectionClick();
            },
          );
        },
      ),
    );
  }

  /// _buildProductCountSection: Shows number of products and filter button
  Widget _buildProductCountSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _VintageProductCount(count: _filteredProducts.length),
          _buildVintageSortButton(),
        ],
      ),
    );
  }

  /// _buildVintageIconButton: Reusable circular icon button with optional badge
  /// Used for search, cart, and menu buttons in header
  Widget _buildVintageIconButton(
    IconData icon,
    VoidCallback onTap, {
    int? badge,
  }) {
    return Container(
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
      child: Stack(
        children: [
          // Main button with ripple effect
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color(0xFFD4AF37).withOpacity(0.8),
                  size: 20,
                ),
              ),
            ),
          ),
          // Badge showing count (e.g., cart items)
          if (badge != null && badge > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    badge.toString(),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// _buildVintageSortButton: Filter/sort button with dropdown functionality
  Widget _buildVintageSortButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showSortBottomSheet();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: const Color(0xFFD4AF37).withOpacity(0.7),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'FILTER',
              style: GoogleFonts.playfairDisplay(
                color: const Color(0xFFD4AF37).withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// _buildVintageProductCard: Wrapper method to create product card widgets
  Widget _buildVintageProductCard(Map<String, dynamic> product, int index) {
    return _VintageProductCard(
      product: product,
      onTap: () => _navigateToProductDetails(product),
      wishlistService: _wishlistService,
    );
  }

  /// _buildFloatingScrollButton: Animated scroll-to-top button
  /// Appears when user scrolls down and disappears when at top
  Widget _buildFloatingScrollButton() {
    return Positioned(
      bottom: 40,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showScrollToTop ? 1.0 : 0.0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _scrollToTop,
              borderRadius: BorderRadius.circular(28),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============== REUSABLE COMPONENT WIDGETS ==============

/// _VintageCategoryChip: Animated category filter chip
/// Changes appearance when selected with gradient background and shadow
class _VintageCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VintageCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                    )
                  : null,
              color: !isSelected ? const Color(0xFF1A1A1A) : null,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFD4AF37).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  color: isSelected
                      ? Colors.black
                      : const Color(0xFFD4AF37).withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.5,
                  shadows: isSelected
                      ? null
                      : [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// _VintageProductCount: Displays filtered product count
class _VintageProductCount extends StatelessWidget {
  final int count;

  const _VintageProductCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFD4AF37),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'PIECES',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD4AF37).withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

/// _VintageProductCard: Individual product card in grid
/// Shows image with badges, rating, and price
class _VintageProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final WishlistService wishlistService;

  const _VintageProductCard({
    required this.product,
    required this.onTap,
    required this.wishlistService,
  });

  @override
  State<_VintageProductCard> createState() => _VintageProductCardState();
}

class _VintageProductCardState extends State<_VintageProductCard> {
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _updateWishlistState();
    widget.wishlistService.addListener(_updateWishlistState);
  }

  @override
  void dispose() {
    widget.wishlistService.removeListener(_updateWishlistState);
    super.dispose();
  }

  void _updateWishlistState() {
    final productId = widget.product['id']?.toString();
    if (productId != null && mounted) {
      setState(() {
        _isInWishlist = widget.wishlistService.isInWishlistSync(productId);
      });
    }
  }

  Future<void> _toggleWishlist() async {
    final productId = widget.product['id']?.toString();
    if (productId == null) return;

    HapticFeedback.lightImpact();

    if (_isInWishlist) {
      await widget.wishlistService.removeFromWishlist(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed from wishlist',
              style: GoogleFonts.inter(color: Colors.black),
            ),
            backgroundColor: const Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      await widget.wishlistService.addToWishlist(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.black, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Added to wishlist',
                  style: GoogleFonts.inter(color: Colors.black),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  /// Helper to display product image from network or assets
  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image from Firebase Storage
      return Image.network(
        imagePath,
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
              size: 40,
            ),
          );
        },
      );
    } else {
      // Local asset image
      return Image.asset(
        imagePath,
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============== IMAGE SECTION ==============
            SizedBox(
              height: 104,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero animation for smooth product image transition
                  Hero(
                    tag: 'product_${product['id']}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: _buildProductImage(product['image']),
                    ),
                  ),
                  // Dark gradient overlay on image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  // NEW badge in top-left
                  if (product['isNew'] == true)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'NEW',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button in top-right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A1A1A).withOpacity(0.8),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggleWishlist,
                          borderRadius: BorderRadius.circular(18),
                          child: Icon(
                            _isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: _isInWishlist
                                ? const Color(0xFFFF3B30)
                                : const Color(0xFFD4AF37).withOpacity(0.7),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============== INFO SECTION ==============
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name - using Flexible instead of fixed height
                    Flexible(
                      child: Text(
                        product['name'] ?? '',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Star rating display
                    SizedBox(
                      height: 20,
                      child: Row(
                        children: [
                          // Generate 5 stars, filled based on rating
                          ...List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                index < (product['rating'] ?? 0).floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 13,
                                color: const Color(0xFFD4AF37).withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Review count - wrapped for better flexibility
                          Flexible(
                            child: Text(
                              '(${product['reviews'] ?? 0})',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFD4AF37).withOpacity(0.5),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price and VIEW button
                    SizedBox(
                      height: 32,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price text
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '\$${(product['price'] ?? 0).toStringAsFixed(0)}',
                                style: GoogleFonts.playfairDisplay(
                                  color: const Color(0xFFD4AF37),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // VIEW button - no flex to maintain size
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'VIEW',
                                style: GoogleFonts.playfairDisplay(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
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

// ============== BOTTOM SHEET WIDGETS ==============

/// _VintageSortBottomSheet: Modal bottom sheet for sorting products
/// Displays various sort options with icons
class _VintageSortBottomSheet extends StatelessWidget {
  final Function(String) onSortSelected;

  const _VintageSortBottomSheet({required this.onSortSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'SORT BY',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          // Sort options
          _buildSortOption(
            'Price: Low to High',
            Icons.arrow_upward_rounded,
            () => onSortSelected('price_low'),
          ),
          _buildSortOption(
            'Price: High to Low',
            Icons.arrow_downward_rounded,
            () => onSortSelected('price_high'),
          ),
          _buildSortOption(
            'Highest Rated',
            Icons.star_rounded,
            () => onSortSelected('rating'),
          ),
          _buildSortOption(
            'Most Popular',
            Icons.trending_up_rounded,
            () => onSortSelected('popular'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// _buildSortOption: Creates individual sort menu item
  Widget _buildSortOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFD4AF37).withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// _VintageSearchBottomSheet: Modal bottom sheet for product search
class _VintageSearchBottomSheet extends StatelessWidget {
  final Function(String) onSearch;

  const _VintageSearchBottomSheet({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle indicator
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'SEARCH',
              style: GoogleFonts.playfairDisplay(
                color: const Color(0xFFD4AF37),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            // Search input field
            TextField(
              autofocus: true,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search for luxury pieces...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  fontSize: 15,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFFD4AF37).withOpacity(0.7),
                    size: 22,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                    size: 22,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                filled: true,
                fillColor: const Color(0xFF0F0F0F),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: onSearch,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
