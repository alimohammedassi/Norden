import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_details.dart';
import '../services/cart_service.dart';
import '../services/backend_product_service.dart';
import '../services/wishlist_service.dart';
import '../services/backend_category_service.dart';
import '../models/product.dart';
import '../models/season.dart';
import '../config/app_theme.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'wishlist_page.dart';
import 'search_page.dart';
import '../providers/season_provider.dart';

// ─────────────────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────────────────
class NordenHomePage extends StatefulWidget {
  final bool showNavIcons;
  const NordenHomePage({Key? key, this.showNavIcons = true}) : super(key: key);
  @override
  State<NordenHomePage> createState() => _NordenHomePageState();
}

class _NordenHomePageState extends State<NordenHomePage>
    with TickerProviderStateMixin {
  // ── Theme / Season ─────────────────────────────────────
  SeasonTokens get t => SeasonScope.of(context).tokens;
  SeasonMode get _season => SeasonScope.of(context).mode;

  // ── Animations ────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _seasonCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _seasonFade;

  // ── Scroll ────────────────────────────────────────────
  final _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  bool _showFab = false;

  // ── Carousel ──────────────────────────────────────────
  final _pageCtrl = PageController(viewportFraction: 0.88);
  int _currentSlide = 0;

  // ── Category ──────────────────────────────────────────
  int _catIndex = 0;
  List<String> _categories = ['All'];
  bool _catsLoading = false;

  // ── Services ──────────────────────────────────────────
  final _productService = BackendProductService();
  final _cartService = CartService();
  final _wishlistService = WishlistService();
  final _categoryService = BackendCategoryService();

  // ── Data ──────────────────────────────────────────────
  final _products = <Map<String, dynamic>>[];

  // ── Winter announcements ───────────────────────────────
  final _winterAnnouncements = <Map<String, dynamic>>[
    {
      'title': 'WINTER\nCOLLECTION',
      'subtitle': 'New Arrivals 2025',
      'description': 'Discover the essence of refined elegance',
      'image': 'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
      'badge': '25% OFF',
    },
    {
      'title': 'LIMITED\nEDITION',
      'subtitle': 'Exclusive Line',
      'description': 'Handcrafted luxury for the discerning gentleman',
      'image': 'assets/images/Trench_coat.jpg',
      'badge': 'MEMBERS ONLY',
    },
    {
      'title': 'BESPOKE\nTAILORING',
      'subtitle': 'Made to Measure',
      'description': 'Your perfect fit, crafted with precision',
      'image': 'assets/images/Double-breasted_blazer.jpg',
      'badge': 'BOOK NOW',
    },
  ];

  // ── Summer announcements ───────────────────────────────
  final _summerAnnouncements = <Map<String, dynamic>>[
    {
      'title': 'SUMMER\nCOLLECTION',
      'subtitle': 'Warm Season 2025',
      'description': 'Light elegance for the season of warmth',
      'image': 'assets/images/Single-breasted_blazer (1).jpg',
      'badge': 'NEW SEASON',
    },
    {
      'title': 'RESORT\nEDITION',
      'subtitle': 'Exclusive Pieces',
      'description': 'Effortless sophistication under the sun',
      'image': 'assets/images/Collarless_blazer.jpg',
      'badge': 'LIMITED',
    },
    {
      'title': 'LIGHT\nTAILORING',
      'subtitle': 'Breathable Luxury',
      'description': 'Premium fabrics that move with you',
      'image': 'assets/images/Tie-belt_denim_jacket.jpg',
      'badge': 'EXPLORE',
    },
  ];

  List<Map<String, dynamic>> get _announcements => _season == SeasonMode.summer
      ? _summerAnnouncements
      : _winterAnnouncements;

  // ── Init ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollCtrl.addListener(_onScroll);
    _cartService.addListener(() {
      if (mounted) setState(() {});
    });
    _wishlistService.loadWishlist();
    _entranceCtrl.forward();
    _autoPlayCarousel();
    _loadSampleProducts();
    _loadCategories();
    _loadFirebaseProducts();
  }

  void _initAnimations() {
    _entranceCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _shimmerCtrl = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);
    _seasonCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.1, 0.9, curve: Curves.easeOutQuart),
          ),
        );
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_shimmerCtrl);
    _seasonFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _seasonCtrl, curve: Curves.easeInOut));
  }

  Future<void> _autoPlayCarousel() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 6));
      if (!mounted) break;
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollCtrl.offset;
      _showFab = _scrollOffset > 380;
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _catsLoading = true);
    try {
      final season = _season == SeasonMode.summer ? 'summer' : 'winter';
      final names = await _categoryService.getCategoryNames(season: season);
      if (mounted) {
        setState(() {
          _categories = ['All', ...names];
          _catIndex = 0;
          _catsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categories = [
            'All',
            'Suits',
            'Blazers',
            'Dress Shirts',
            'Trousers',
            'Coats',
            'Accessories',
          ];
          _catsLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(() {});
    _entranceCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _seasonCtrl.dispose();
    _scrollCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────
  Map<String, dynamic> toMap(Product p) => {
    'id': p.id,
    'name': p.name,
    'price': p.price,
    'image': p.images.isNotEmpty
        ? p.images[0]
        : 'assets/images/Double-breasted_blazer.jpg',
    'imageUrl': p.images.isNotEmpty ? p.images[0] : '',
    'category': p.category,
    'rating': p.rating,
    'reviewCount': p.reviewCount,
    'reviews': p.reviewCount,
    'isNew': p.isNew,
    'isFeatured': p.isFeatured,
    'season': p.season,
    'colors': p.colors,
    'sizes': p.sizes,
    'description': p.description,
    'additionalImages': p.images.length > 1 ? p.images.sublist(1) : [],
  };

  void _loadSampleProducts() {
    _products.clear();
    if (mounted) setState(() {});
  }

  void _loadFirebaseProducts() async {
    try {
      final ps = await _productService.getProducts();
      if (!mounted) return;
      setState(() {
        _products.clear();
        _products.addAll(ps.map(toMap));
      });
    } catch (_) {
      // Empty fallback instead of loading fake products
      if (mounted) setState(() { _products.clear(); });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    List<Map<String, dynamic>> list = _products;

    // Filter by season
    if (_season == SeasonMode.winter) {
      list = list
          .where((p) => p['season'] == 'winter' || p['season'] == 'all')
          .toList();
    } else {
      list = list
          .where((p) => p['season'] == 'summer' || p['season'] == 'all')
          .toList();
    }

    // Filter by category
    if (_catIndex != 0 && _catIndex < _categories.length) {
      final cat = _categories[_catIndex];
      list = list.where((p) => p['category'] == cat).toList();
    }
    return list;
  }

  // ── Season switch ─────────────────────────────────────
  void _switchSeason(SeasonMode mode) {
    if (mode == _season) return;
    HapticFeedback.mediumImpact();
    SeasonScope.read(context).switchTo(mode);
    setState(() {
      _catIndex = 0;
      _currentSlide = 0;
    });
    _seasonCtrl.forward(from: 0);
    _loadCategories();
  }

  // ── Navigation ────────────────────────────────────────
  void _goProduct(Map<String, dynamic> product) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      _fadeSlide(() => ProductDetailsPage(product: product)),
    );
  }

  PageRouteBuilder _fadeSlide(Widget Function() builder) => PageRouteBuilder(
    pageBuilder: (_, a, __) => builder(),
    transitionsBuilder: (_, a, __, child) => FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
    transitionDuration: const Duration(milliseconds: 420),
  );

  // ─────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      color: t.bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildBackground(t),
            SafeArea(
              child: CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // ── Header
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildHeader(t),
                    ),
                  ),

                  // ── Season Switcher
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildSeasonSwitcher(t),
                    ),
                  ),

                  // ── Cinematic Carousel
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildCarousel(t),
                      ),
                    ),
                  ),

                  // ── Section Label
                  SliverToBoxAdapter(child: _buildSectionLabel(t)),

                  // ── Product Count Row
                  SliverToBoxAdapter(child: _buildCountRow(t)),

                  // ── Category Section (separate block while scrolling)
                  SliverToBoxAdapter(child: _buildCategorySection(t)),

                  // ── Product Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.66,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                          ),
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        final p = _filtered[i];
                        return _ProductCard(
                          product: p,
                          onTap: () => _goProduct(p),
                          wishlistService: _wishlistService,
                          cartService: _cartService,
                          index: i,
                          tokens: t,
                        );
                      }, childCount: _filtered.length),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),

            // ── FAB
            if (_showFab) _buildFab(t),
          ],
        ),
      ),
    );
  }

  // ── Background ────────────────────────────────────────
  Widget _buildBackground(SeasonTokens t) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.bg, t.surface, t.surface2, t.bg],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [t.gold.withOpacity(0.07), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeader(SeasonTokens t) {
    final headerOpacity = (1 - (_scrollOffset / 160)).clamp(0.0, 1.0);
    return Opacity(
      opacity: headerOpacity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
        child: Row(
          children: [
            Expanded(
              child: _AnimatedLogo(shimmerAnim: _shimmerAnim, tokens: t),
            ),
            _HeaderIcon(
              icon: Icons.search_rounded,
              onTap: _showSearch,
              tokens: t,
            ),
            if (widget.showNavIcons) ...[
              const SizedBox(width: 8),
              _HeaderIcon(
                icon: Icons.favorite_border_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    _fadeSlide(() => const WishlistPage()),
                  );
                },
                tokens: t,
              ),
              const SizedBox(width: 8),
              _HeaderIcon(
                icon: Icons.person_outline_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    _fadeSlide(() => const ProfilePage()),
                  );
                },
                tokens: t,
              ),
              const SizedBox(width: 8),
              _HeaderIcon(
                icon: Icons.shopping_bag_outlined,
                badge: _cartService.itemCount,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, _fadeSlide(() => const CartPage()));
                },
                tokens: t,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Season Switcher ───────────────────────────────────
  Widget _buildSeasonSwitcher(SeasonTokens t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: t.border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SeasonTab(
                label: '❄  WINTER',
                isActive: _season == SeasonMode.winter,
                onTap: () => _switchSeason(SeasonMode.winter),
                tokens: t,
              ),
            ),
            Expanded(
              child: _SeasonTab(
                label: '☀  SUMMER',
                isActive: _season == SeasonMode.summer,
                onTap: () => _switchSeason(SeasonMode.summer),
                tokens: t,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carousel ─────────────────────────────────────────
  Widget _buildCarousel(SeasonTokens t) {
    // Blend announcements with featured products (images from backend)
    final featuredProducts = _products
        .where((p) => p['isFeatured'] == true || p['isNew'] == true)
        .take(4)
        .toList();

    // Build slides: start with the editorial announcements, append product slides
    final announcementSlides = _announcements.map((a) => {
      'title': a['title'],
      'subtitle': a['subtitle'],
      'description': a['description'],
      'badge': a['badge'],
      'image': a['image'],
      'isProduct': false,
    }).toList();

    final productSlides = featuredProducts.map((p) => {
      'title': (p['name'] as String? ?? '').toUpperCase(),
      'subtitle': p['category'] as String? ?? '',
      'description': p['description'] as String? ?? 'Discover this exclusive piece',
      'badge': p['isNew'] == true ? 'NEW ARRIVAL' : 'FEATURED',
      'image': p['image'] as String? ?? '',
      'isProduct': true,
      'product': p,
    }).toList();

    final slides = [...announcementSlides, ...productSlides];
    if (slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 248,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: 9999,
            onPageChanged: (i) =>
                setState(() => _currentSlide = i % slides.length),
            itemBuilder: (_, i) {
              final a = slides[i % slides.length];
              return _CarouselCard(data: a, tokens: t, onTap: a['isProduct'] == true ? () => _goProduct(a['product'] as Map<String, dynamic>) : null);
            },
          ),
        ),
        const SizedBox(height: 14),
        _SlideIndicator(
          current: _currentSlide % slides.length,
          total: slides.length,
          tokens: t,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  // ── Section Label ─────────────────────────────────────
  Widget _buildSectionLabel(SeasonTokens t) {
    final label = _season == SeasonMode.winter
        ? 'WINTER COLLECTIONS'
        : 'SUMMER COLLECTIONS';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: _GradientDivider(leftToRight: true, tokens: t)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.diamond_outlined,
                  size: 10,
                  color: t.gold.withOpacity(0.5),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 11,
                    color: t.gold.withOpacity(0.8),
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.diamond_outlined,
                  size: 10,
                  color: t.gold.withOpacity(0.5),
                ),
              ],
            ),
          ),
          Expanded(child: _GradientDivider(leftToRight: false, tokens: t)),
        ],
      ),
    );
  }

  // ── Category Section (separate section while scrolling) ──────────────────
  Widget _buildCategorySection(SeasonTokens t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.gold.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: t.gold.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [t.goldLight, t.goldDark],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'BROWSE BY CATEGORY',
                  style: GoogleFonts.cormorantGaramond(
                    color: t.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.grid_view_rounded, color: t.gold.withOpacity(0.5), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 2),
          _buildCategoryTabs(t),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ── Category Tabs ─────────────────────────────────────
  Widget _buildCategoryTabs(SeasonTokens t) {
    if (_catsLoading) {
      return SizedBox(
        height: 48,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (_, i) => Container(
            margin: const EdgeInsets.only(right: 10),
            width: 90,
            height: 38,
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              border: Border.all(color: t.border),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (_, i) => _CategoryTab(
          label: _categories[i],
          isSelected: i == _catIndex,
          tokens: t,
          onTap: () {
            setState(() => _catIndex = i);
            HapticFeedback.selectionClick();
          },
        ),
      ),
    );
  }

  // ── Count Row ─────────────────────────────────────────
  Widget _buildCountRow(SeasonTokens t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_filtered.length} ',
                  style: GoogleFonts.cormorantGaramond(
                    color: t.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'pieces',
                  style: GoogleFonts.cormorantGaramond(
                    color: t.subtext,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _FilterButton(onTap: _showSort, tokens: t),
        ],
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────
  Widget _buildFab(SeasonTokens t) {
    return Positioned(
      bottom: 32,
      right: 20,
      child: AnimatedOpacity(
        opacity: _showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 280),
        child: GestureDetector(
          onTap: () {
            _scrollCtrl.animateTo(
              0,
              duration: const Duration(milliseconds: 580),
              curve: Curves.easeInOutCubic,
            );
            HapticFeedback.mediumImpact();
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [t.goldLight, t.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: t.gold.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.keyboard_arrow_up_rounded, color: t.bg, size: 26),
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheets ─────────────────────────────────────
  void _showSort() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _SortSheet(onSort: (s) => Navigator.pop(context), tokens: t),
    );
  }

  void _showSearch() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SEASON TAB
// ─────────────────────────────────────────────────────────
class _SeasonTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final SeasonTokens tokens;
  const _SeasonTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [t.goldLight, t.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: const BorderRadius.all(Radius.circular(17)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cormorantGaramond(
              color: isActive ? t.bg : t.subtext,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  ANIMATED LOGO
// ─────────────────────────────────────────────────────────
class _AnimatedLogo extends StatelessWidget {
  final Animation<double> shimmerAnim;
  final SeasonTokens tokens;
  const _AnimatedLogo({required this.shimmerAnim, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return AnimatedBuilder(
      animation: shimmerAnim,
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [t.gold, t.goldLight, t.gold],
          stops: [
            (shimmerAnim.value - 0.3).clamp(0.0, 0.4),
            (shimmerAnim.value).clamp(0.3, 0.7),
            (shimmerAnim.value + 0.3).clamp(0.6, 1.0),
          ],
        ).createShader(bounds),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NORDEN',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 8,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(width: 24, height: 1, color: t.gold.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(
                  'MAISON DE LUXE',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 10,
                    color: t.gold.withOpacity(0.6),
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  HEADER ICON
// ─────────────────────────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  final SeasonTokens tokens;
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    this.badge,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: t.surface,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: t.border, width: 1),
              ),
              child: Icon(icon, color: t.gold.withOpacity(0.85), size: 18),
            ),
          ),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [t.goldLight, t.goldDark]),
                shape: BoxShape.circle,
                border: Border.all(color: t.bg, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              child: Center(
                child: Text(
                  '$badge',
                  style: GoogleFonts.inter(
                    color: t.bg,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  CAROUSEL CARD
// ─────────────────────────────────────────────────────────
class _CarouselCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final SeasonTokens tokens;
  final VoidCallback? onTap;
  const _CarouselCard({required this.data, required this.tokens, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: t.gold.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(data['image']),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.88),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            // Bottom tint
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Gold accent line
            Positioned(
              left: 0,
              top: 20,
              bottom: 20,
              width: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      t.gold,
                      t.gold,
                      Colors.transparent,
                    ],
                    stops: const [0, 0.2, 0.8, 1],
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(2),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: t.gold.withOpacity(0.15),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                      border: Border.all(
                        color: t.gold.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      data['badge'],
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: t.gold,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  // Texts
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['subtitle'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 11,
                          color: t.gold.withOpacity(0.85),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.75),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'EXPLORE',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 11,
                              color: t.gold,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 1,
                            color: t.gold.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: t.gold,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Border
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: t.gold.withOpacity(0.15), width: 1),
                ),
              ),
            ),
          ],
        ),
      ), // closes ClipRRect
      ), // closes Container
    ); // closes GestureDetector
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF181818)),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF181818)),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SLIDE INDICATOR
// ─────────────────────────────────────────────────────────
class _SlideIndicator extends StatelessWidget {
  final int current, total;
  final SeasonTokens tokens;
  const _SlideIndicator({
    required this.current,
    required this.total,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 28 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            color: active ? tokens.gold : tokens.border,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  CATEGORY TAB
// ─────────────────────────────────────────────────────────
class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final SeasonTokens tokens;
  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      margin: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [t.goldLight, t.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : t.surface,
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              border: Border.all(
                color: isSelected ? t.gold : t.border,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: t.gold.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.cormorantGaramond(
                color: isSelected ? t.bg : t.subtext,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  FILTER BUTTON
// ─────────────────────────────────────────────────────────
class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final SeasonTokens tokens;
  const _FilterButton({required this.onTap, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Material(
      color: t.surface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: t.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: t.gold.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'FILTER',
                style: GoogleFonts.cormorantGaramond(
                  color: t.gold.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────
class _GradientDivider extends StatelessWidget {
  final bool leftToRight;
  final SeasonTokens tokens;
  const _GradientDivider({required this.leftToRight, required this.tokens});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: leftToRight
            ? [Colors.transparent, tokens.gold.withOpacity(0.3)]
            : [tokens.gold.withOpacity(0.3), Colors.transparent],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────
//  PRODUCT CARD  — Premium editorial style
// ─────────────────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final WishlistService wishlistService;
  final CartService cartService; // NEW — for quick-add
  final int index;
  final SeasonTokens tokens;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.wishlistService,
    required this.cartService,
    required this.index,
    required this.tokens,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  bool _inWish = false;
  bool _addedToCart = false;
  bool _isPressed = false;
  int _selectedColorIndex = 0;

  // ── Controllers ───────────────────────────────────────────────────────────
  late AnimationController _heartCtrl;
  late AnimationController _entryCtrl;
  late AnimationController _cartCtrl;

  late Animation<double> _heartScale;
  late Animation<double> _entryOpacity;
  late Animation<Offset> _entrySlide;
  late Animation<double> _cartScale;

  @override
  void initState() {
    super.initState();

    // Heart bounce
    _heartCtrl = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));

    // Staggered card entry — fade + slide from bottom-right
    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _entryOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
    ));

    // Quick-add micro-animation
    _cartCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.78), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.78, end: 1.12), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _cartCtrl, curve: Curves.easeInOut));

    // Staggered reveal
    Future.delayed(Duration(milliseconds: 60 + widget.index * 55), () {
      if (mounted) _entryCtrl.forward();
    });

    _sync();
    widget.wishlistService.addListener(_sync);
  }

  @override
  void dispose() {
    widget.wishlistService.removeListener(_sync);
    _heartCtrl.dispose();
    _entryCtrl.dispose();
    _cartCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final id = widget.product['id']?.toString();
    if (id != null && mounted) {
      setState(() => _inWish = widget.wishlistService.isInWishlistSync(id));
    }
  }

  Future<void> _toggleWish() async {
    final id = widget.product['id']?.toString();
    if (id == null) return;
    HapticFeedback.lightImpact();
    _heartCtrl.forward(from: 0);
    if (_inWish) {
      await widget.wishlistService.removeFromWishlist(id);
    } else {
      await widget.wishlistService.addToWishlist(id);
    }
  }

  Future<void> _quickAddToCart() async {
    if (_isOutOfStock) return;
    HapticFeedback.mediumImpact();
    await _cartCtrl.forward(from: 0);
    if (mounted) {
      setState(() => _addedToCart = true);

      final colors = widget.product['colors'] as List?;
      widget.cartService.addItem(
        productId: widget.product['id']?.toString() ?? '',
        quantity: 1,
        selectedColor: colors != null && colors.isNotEmpty ? colors[0].toString() : 'Default',
        selectedSize: 'M',
        productName: widget.product['name']?.toString(),
        price: (widget.product['price'] as num?)?.toDouble(),
        imageUrl: widget.product['imageUrl']?.toString() ?? widget.product['image']?.toString(),
      );

      // Animate the cart icon back after 1.5s
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _addedToCart = false);
    }
  }

  // ── Derived ───────────────────────────────────────────────────────────────
  bool get _isOutOfStock => widget.product['outOfStock'] == true;
  bool get _isNew => widget.product['isNew'] == true;
  double? get _originalPrice => (widget.product['originalPrice'] as num?)?.toDouble();
  double get _price => (widget.product['price'] ?? 0).toDouble();
  bool get _onSale =>
      _originalPrice != null && _originalPrice! > _price;
  int get _discountPct =>
      _onSale ? ((_originalPrice! - _price) / _originalPrice! * 100).round() : 0;

  List<Color> get _colorVariants {
    final raw = widget.product['colors'] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return [];
    final result = <Color>[];
    for (final c in raw) {
      final color = _parseColor(c.toString());
      if (color != null) result.add(color);
    }
    return result;
  }

  static Color? _parseColor(String value) {
    // Handle hex: #RRGGBB or #AARRGGBB
    final hex = value.trim().replaceFirst('#', '');
    if (hex.length == 6 || hex.length == 8) {
      final padded = hex.length == 6 ? 'FF$hex' : hex;
      final parsed = int.tryParse(padded, radix: 16);
      if (parsed != null) return Color(parsed);
    }
    // Handle named colors
    const namedColors = {
      'red': Color(0xFFE53935),
      'blue': Color(0xFF1E88E5),
      'green': Color(0xFF43A047),
      'black': Color(0xFF212121),
      'white': Color(0xFFF5F5F5),
      'grey': Color(0xFF757575),
      'gray': Color(0xFF757575),
      'navy': Color(0xFF1A237E),
      'yellow': Color(0xFFFDD835),
      'orange': Color(0xFFE65100),
      'pink': Color(0xFFEC407A),
      'purple': Color(0xFF7B1FA2),
      'brown': Color(0xFF5D4037),
      'beige': Color(0xFFF5F0E8),
      'khaki': Color(0xFFC8B96E),
      'gold': Color(0xFFD4A843),
      'silver': Color(0xFFB0BEC5),
      'cream': Color(0xFFFFF8E1),
      'ivory': Color(0xFFFFFAF0),
      'olive': Color(0xFF827717),
      'teal': Color(0xFF00695C),
      'cyan': Color(0xFF00ACC1),
      'indigo': Color(0xFF283593),
      'maroon': Color(0xFF880E4F),
      'charcoal': Color(0xFF37474F),
    };
    return namedColors[value.trim().toLowerCase()];
  }

  // ── Image helpers ─────────────────────────────────────────────────────────
  Widget _img(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, p) =>
            p == null ? child : _loadingShimmer(),
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorPlaceholder(),
    );
  }

  Widget _loadingShimmer() {
    final t = widget.tokens;
    return Container(
      color: t.surface2,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: t.gold.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    final t = widget.tokens;
    return Container(
      color: t.surface2,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: t.gold.withOpacity(0.2),
          size: 28,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final image = widget.product['image'] as String? ?? '';

    return FadeTransition(
      opacity: _entryOpacity,
      child: SlideTransition(
        position: _entrySlide,
        child: GestureDetector(
          onTap: _isOutOfStock ? null : widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) =>
              Future.delayed(const Duration(milliseconds: 120),
                  () { if (mounted) setState(() => _isPressed = false); }),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: _isPressed
                      ? t.gold.withOpacity(0.35)
                      : t.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: _isPressed ? 8 : 20,
                    offset: Offset(0, _isPressed ? 3 : 8),
                  ),
                  if (!_isOutOfStock && !_isPressed)
                    BoxShadow(
                      color: t.gold.withOpacity(0.04),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image zone (flexible ~62%)
                  Expanded(
                    flex: 62,
                    child: _buildImageZone(image, t),
                  ),
                  // ── Info zone (flexible ~38%)
                  Expanded(
                    flex: 38,
                    child: _buildInfoZone(t),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Image zone ─────────────────────────────────────────────────────────────
  Widget _buildImageZone(String image, SeasonTokens t) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product image with Hero
          Hero(
            tag: 'product_${widget.product['id']}',
            child: _img(image),
          ),

          // Bottom gradient — taller for better readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Out of stock overlay
          if (_isOutOfStock)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    'OUT OF STOCK',
                    style: GoogleFonts.dmMono(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Top row: badge (left) + heart (right)
          Positioned(
            top: 9,
            left: 10,
            right: 9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // NEW or SALE badge — only one at a time
                if (_isNew && !_onSale)
                  _buildBadge(
                    'NEW',
                    gradient: LinearGradient(
                      colors: [t.goldLight, t.goldDark],
                    ),
                    textColor: Colors.black,
                  )
                else if (_onSale)
                  _buildBadge(
                    '−$_discountPct%',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B5A), Color(0xFFFF3B30)],
                    ),
                    textColor: Colors.white,
                  )
                else
                  const SizedBox.shrink(),

                // Animated heart button
                AnimatedBuilder(
                  animation: _heartScale,
                  builder: (_, __) => Transform.scale(
                    scale: _heartScale.value,
                    child: GestureDetector(
                      onTap: _toggleWish,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: t.bg.withOpacity(0.82),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _inWish
                                ? SeasonTokens.red.withOpacity(0.4)
                                : t.border,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _inWish
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          size: 15,
                          color: _inWish
                              ? SeasonTokens.red
                              : t.gold.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom row: price (left) + quick-add (right)
          Positioned(
            bottom: 9,
            left: 10,
            right: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Price pill — shows original crossed-out if on sale
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: t.bg.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: t.gold.withOpacity(0.22),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_onSale) ...[
                        Text(
                          '\$${_originalPrice!.toStringAsFixed(0)}',
                          style: GoogleFonts.dmMono(
                            color: t.gold.withOpacity(0.35),
                            fontSize: 9,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '\$${_price.toStringAsFixed(0)}',
                        style: GoogleFonts.cormorantGaramond(
                          color: t.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Quick-add button with animated feedback
                if (!_isOutOfStock)
                  AnimatedBuilder(
                    animation: _cartCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _cartScale.value,
                      child: GestureDetector(
                        onTap: _quickAddToCart,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _addedToCart
                                  ? [
                                      const Color(0xFF30D158),
                                      const Color(0xFF25B44A),
                                    ]
                                  : [t.goldLight, t.goldDark],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_addedToCart
                                    ? const Color(0xFF30D158)
                                    : t.gold)
                                    .withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _addedToCart
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            size: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info zone ──────────────────────────────────────────────────────────────
  Widget _buildInfoZone(SeasonTokens t) {
    final name = widget.product['name'] as String? ?? '';
    final rating = (widget.product['rating'] ?? 4.8) as double;
    final reviewCount = (widget.product['reviewCount'] ?? 0) as int;
    final colors = _colorVariants;

    return Padding(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Product name — 2 lines max, larger + more readable
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cormorantGaramond(
                color: _isOutOfStock
                    ? t.text.withOpacity(0.4)
                    : t.text,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),

          // Bottom row: stars (left) + color dots (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Stars + rating
              Icon(Icons.star_rounded, size: 12, color: t.gold),
              const SizedBox(width: 3),
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.dmMono(
                  color: t.gold.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  '(${reviewCount > 999 ? '999+' : reviewCount})',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmMono(
                    color: t.subtext,
                    fontSize: 10,
                  ),
                ),
              ),

              const Spacer(),

              // Color variant dots
              if (colors.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    colors.length.clamp(0, 4),
                    (i) => GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[i],
                          border: Border.all(
                            color: _selectedColorIndex == i
                                ? t.gold.withOpacity(0.7)
                                : Colors.white.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Badge helper ──────────────────────────────────────────────────────────
  Widget _buildBadge(
    String label, {
    required Gradient gradient,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.dmMono(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SORT BOTTOM SHEET
// ─────────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final Function(String) onSort;
  final SeasonTokens tokens;
  const _SortSheet({required this.onSort, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final options = [
      ('Price: Low to High', Icons.arrow_upward_rounded, 'price_low'),
      ('Price: High to Low', Icons.arrow_downward_rounded, 'price_high'),
      ('Highest Rated', Icons.star_rounded, 'rating'),
      ('Most Popular', Icons.trending_up_rounded, 'popular'),
      ('Newest First', Icons.fiber_new_rounded, 'newest'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: t.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: t.border,
                borderRadius: const BorderRadius.all(Radius.circular(32)),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'SORT BY',
            style: GoogleFonts.cormorantGaramond(
              color: t.gold,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 18),
          ...options.map(
            (o) => _SortOption(
              title: o.$1,
              icon: o.$2,
              onTap: () => onSort(o.$3),
              tokens: t,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final SeasonTokens tokens;
  const _SortOption({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: t.surface2,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: t.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: t.gold.withOpacity(0.7), size: 18),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cormorantGaramond(
                    color: t.text.withOpacity(0.88),
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: t.subtext, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}


