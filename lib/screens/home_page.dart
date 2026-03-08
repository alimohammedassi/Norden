import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_details.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/wishlist_service.dart';
import '../services/backend_category_service.dart';
import '../models/product.dart';
import '../models/season.dart';
import '../config/app_theme.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'wishlist_page.dart';

// ─────────────────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────────────────
class NordenHomePage extends StatefulWidget {
  const NordenHomePage({Key? key}) : super(key: key);
  @override
  State<NordenHomePage> createState() => _NordenHomePageState();
}

class _NordenHomePageState extends State<NordenHomePage>
    with TickerProviderStateMixin {
  // ── Theme / Season ─────────────────────────────────────
  SeasonMode _season = SeasonMode.winter;
  SeasonTokens get _t => AppTheme.of(_season);

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
  final _productService = ProductService();
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
    _shimmerAnim = Tween<double>(begin: -2.0, end: 2.0).animate(_shimmerCtrl);
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
  Map<String, dynamic> _toMap(Product p) => {
    'id': p.id,
    'name': p.name,
    'price': p.price,
    'image': p.images.isNotEmpty
        ? p.images[0]
        : 'assets/images/Double-breasted_blazer.jpg',
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
    final sp = Product.getSampleProducts();
    _products
      ..clear()
      ..addAll(sp.map(_toMap));
    if (mounted) setState(() {});
  }

  void _loadFirebaseProducts() async {
    try {
      final ps = await _productService.getProducts();
      if (!mounted) return;
      setState(() {
        _products.clear();
        _products.addAll(
          ps.isNotEmpty
              ? ps.map(_toMap)
              : Product.getSampleProducts().map(_toMap),
        );
      });
    } catch (_) {
      if (mounted) setState(_loadSampleProducts);
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
    setState(() {
      _season = mode;
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
    final t = _t;
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

                  // ── Category Tabs
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildCategoryTabs(t),
                    ),
                  ),

                  // ── Product Count Row
                  SliverToBoxAdapter(child: _buildCountRow(t)),

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
                          index: i,
                          tokens: t,
                        );
                      }, childCount: _filtered.length),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
            const SizedBox(width: 8),
            _HeaderIcon(
              icon: Icons.favorite_border_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(context, _fadeSlide(() => const WishlistPage()));
              },
              tokens: t,
            ),
            const SizedBox(width: 8),
            _HeaderIcon(
              icon: Icons.person_outline_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(context, _fadeSlide(() => const ProfilePage()));
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
    return Column(
      children: [
        SizedBox(
          height: 248,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: 9999,
            onPageChanged: (i) =>
                setState(() => _currentSlide = i % _announcements.length),
            itemBuilder: (_, i) {
              final a = _announcements[i % _announcements.length];
              return _CarouselCard(data: a, tokens: t);
            },
          ),
        ),
        const SizedBox(height: 14),
        _SlideIndicator(
          current: _currentSlide,
          total: _announcements.length,
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
          _SortSheet(onSort: (s) => Navigator.pop(context), tokens: _t),
    );
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SearchSheet(
        tokens: _t,
        onSearch: (q) {
          // TODO: wire to BackendProductService.searchProducts(query: q)
        },
      ),
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
            (shimmerAnim.value - 0.3).clamp(0.0, 1.0),
            shimmerAnim.value.clamp(0.0, 1.0),
            (shimmerAnim.value + 0.3).clamp(0.0, 1.0),
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
                    fontSize: 9,
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
  const _CarouselCard({required this.data, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
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
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 11,
                          color: t.gold.withOpacity(0.85),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['title'],
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
      ),
    );
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
  final int index;
  final SeasonTokens tokens;
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.wishlistService,
    required this.index,
    required this.tokens,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  bool _inWish = false;
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));
    _sync();
    widget.wishlistService.addListener(_sync);
  }

  @override
  void dispose() {
    widget.wishlistService.removeListener(_sync);
    _heartCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final id = widget.product['id']?.toString();
    if (id != null && mounted)
      setState(() => _inWish = widget.wishlistService.isInWishlistSync(id));
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

  Widget _img(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, p) => p == null ? child : _loadingShimmer(),
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
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: t.gold.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    final t = widget.tokens;
    return Container(
      color: t.surface2,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: t.gold.withOpacity(0.2),
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final t = widget.tokens;
    final name = p['name'] ?? '';
    final price = (p['price'] ?? 0).toStringAsFixed(0);
    final rating = (p['rating'] ?? 4.8) as double;
    final reviewCount = (p['reviewCount'] ?? 0) as int;
    final isNew = p['isNew'] == true;
    final image = p['image'] as String? ?? '';

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250 + widget.index * 40),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: t.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Area (60%)
            Expanded(
              flex: 60,
              child: Stack(
                children: [
                  // Full image
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Hero(
                        tag: 'product_${p['id']}',
                        child: _img(image),
                      ),
                    ),
                  ),
                  // Bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // NEW badge
                  if (isNew)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [t.goldLight, t.goldDark],
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(32),
                          ),
                        ),
                        child: Text(
                          'NEW',
                          style: GoogleFonts.cormorantGaramond(
                            color: t.bg,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  // Heart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedBuilder(
                      animation: _heartScale,
                      builder: (_, __) => Transform.scale(
                        scale: _heartScale.value,
                        child: GestureDetector(
                          onTap: _toggleWish,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: t.bg.withOpacity(0.85),
                              shape: BoxShape.circle,
                              border: Border.all(color: t.border, width: 1),
                            ),
                            child: Icon(
                              _inWish
                                  ? Icons.favorite
                                  : Icons.favorite_border_rounded,
                              size: 16,
                              color: _inWish
                                  ? SeasonTokens.red
                                  : t.gold.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Price pill
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: t.bg.withOpacity(0.9),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(32),
                        ),
                        border: Border.all(
                          color: t.gold.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '\$$price',
                        style: GoogleFonts.cormorantGaramond(
                          color: t.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info Area (40%)
            Expanded(
              flex: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          color: t.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded, size: 13, color: t.gold),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: GoogleFonts.cormorantGaramond(
                                  color: t.gold.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '(${reviewCount > 999 ? '999+' : reviewCount})',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cormorantGaramond(
                                    color: t.subtext,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: t.gold.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: t.gold.withOpacity(0.8),
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

// ─────────────────────────────────────────────────────────
//  SEARCH BOTTOM SHEET
// ─────────────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  final Function(String) onSearch;
  final SeasonTokens tokens;
  const _SearchSheet({required this.onSearch, required this.tokens});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: t.border, width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
              'SEARCH',
              style: GoogleFonts.cormorantGaramond(
                color: t.gold,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: t.surface2,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: t.border),
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: GoogleFonts.inter(color: t.text, fontSize: 15),
                cursorColor: t.gold,
                decoration: InputDecoration(
                  hintText: 'Search NORDEN collections...',
                  hintStyle: GoogleFonts.inter(color: t.subtext, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: t.gold.withOpacity(0.6),
                    size: 20,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _ctrl,
                    builder: (_, v, __) => v.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: t.subtext,
                              size: 18,
                            ),
                            onPressed: _ctrl.clear,
                          ),
                  ),
                ),
                onSubmitted: (q) {
                  if (q.isNotEmpty) {
                    widget.onSearch(q);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_ctrl.text.isNotEmpty) {
                    widget.onSearch(_ctrl.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.gold,
                  foregroundColor: t.bg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'SEARCH',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: t.bg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
