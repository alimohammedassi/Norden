import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/backend_product_service.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../models/product.dart';
import '../config/app_theme.dart';
import '../providers/season_provider.dart';
import 'product_details.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();
  final _productService = BackendProductService();
  final _cartService = CartService();
  final _wishlistService = WishlistService();

  String _selectedCategory = 'All';
  String _currentQuery = '';

  List<Product> _products = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _currentQuery = query.trim();
        _isLoading = true;
      });
      _fetchProducts();
    });
  }

  void _onCategorySelected(String category) {
    HapticFeedback.lightImpact();
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final categoryFilter = _selectedCategory == 'All' ? null : _selectedCategory;
      final results = await _productService.searchProducts(
        query: _currentQuery,
        category: categoryFilter,
      );
      if (mounted) {
        setState(() {
          _products = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> toMap(Product p) => {
    'id': p.id,
    'name': p.name,
    'price': p.price,
    'image': p.images.isNotEmpty ? p.images.first : '',
    'category': p.category,
    'rating': p.rating,
    'reviewCount': p.reviewCount,
    'isNew': p.isNew,
    'colors': p.colors,
  };

  @override
  Widget build(BuildContext context) {
    // We use the SeasonScope to get thematic colors
    final t = SeasonScope.of(context).tokens;
    final categories = SeasonScope.of(context).categories;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header & Search Bar ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  _circleBtn(
                    Icons.arrow_back_ios_new_rounded,
                    () => Navigator.pop(context),
                    t,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: t.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.border),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: GoogleFonts.inter(color: t.text, fontSize: 14),
                        cursorColor: t.gold,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search NORDEN collections...',
                          hintStyle: GoogleFonts.inter(
                            color: t.subtext,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: t.gold.withOpacity(0.6),
                            size: 20,
                          ),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchCtrl,
                            builder: (_, v, __) => v.text.isEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: t.subtext,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      _onSearchChanged('');
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Categories Bar ───
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () => _onCategorySelected(cat),
                      tokens: t,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Container(height: 1, color: t.border),

            // ─── Product Grid ───
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: t.gold,
                        strokeWidth: 2,
                      ),
                    )
                  : _products.isEmpty
                      ? _buildEmptyState(t)
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return _ProductCard(
                              product: toMap(_products[index]),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsPage(product: toMap(_products[index])),
                                ),
                              ),
                              wishlistService: _wishlistService,
                              cartService: _cartService,
                              index: index,
                              tokens: t,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(SeasonTokens t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: t.gold.withOpacity(0.2),
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            'NO RESULTS FOUND',
            style: GoogleFonts.cormorantGaramond(
              color: t.gold,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or selecting a different category.',
            style: GoogleFonts.dmMono(
              color: t.subtext,
              fontSize: 11,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, SeasonTokens t) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: t.gold.withOpacity(0.07),
            border: Border.all(color: t.gold.withOpacity(0.15)),
          ),
          child: Icon(icon, color: t.gold, size: 20),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final SeasonTokens tokens;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? t.gold.withOpacity(0.15) : t.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? t.gold : t.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.dmMono(
            color: isSelected ? t.gold : t.text.withOpacity(0.8),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final WishlistService wishlistService;
  final CartService cartService;
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
  bool _inWish = false;
  bool _addedToCart = false;
  bool _isPressed = false;
  int _selectedColorIndex = 0;

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

    _heartCtrl = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));

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

    _cartCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.78), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.78, end: 1.12), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _cartCtrl, curve: Curves.easeInOut));

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
      // add to real cart service
      final colors = widget.product['colors'] as List?;
      widget.cartService.addItem(
        productId: widget.product['id']?.toString() ?? '',
        quantity: 1,
        selectedColor: colors != null && colors.isNotEmpty ? colors[0].toString() : 'Default',
        selectedSize: 'M',
        productName: widget.product['name']?.toString(),
        price: (widget.product['price'] as num?)?.toDouble(),
        imageUrl: widget.product['image']?.toString(),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _addedToCart = false);
    }
  }

  bool get _isOutOfStock => widget.product['outOfStock'] == true;
  bool get _isNew => widget.product['isNew'] == true;
  double? get _originalPrice => (widget.product['originalPrice'] as num?)?.toDouble();
  double get _price => (widget.product['price'] ?? 0).toDouble();
  bool get _onSale => _originalPrice != null && _originalPrice! > _price;
  int get _discountPct => _onSale ? ((_originalPrice! - _price) / _originalPrice! * 100).round() : 0;

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
    final hex = value.trim().replaceFirst('#', '');
    if (hex.length == 6 || hex.length == 8) {
      final padded = hex.length == 6 ? 'FF$hex' : hex;
      final parsed = int.tryParse(padded, radix: 16);
      if (parsed != null) return Color(parsed);
    }
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

  Widget _img(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, p) => p == null ? child : _loadingShimmer(),
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorPlaceholder());
  }

  Widget _loadingShimmer() {
    final t = widget.tokens;
    return Container(
      color: t.surface2,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: t.gold.withOpacity(0.4)),
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    final t = widget.tokens;
    return Container(
      color: t.surface2,
      child: Center(child: Icon(Icons.image_not_supported_outlined, color: t.gold.withOpacity(0.2), size: 28)),
    );
  }

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
          onTapUp: (_) => Future.delayed(const Duration(milliseconds: 120), () { if (mounted) setState(() => _isPressed = false); }),
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
                border: Border.all(color: _isPressed ? t.gold.withOpacity(0.35) : t.border, width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: _isPressed ? 8 : 20, offset: Offset(0, _isPressed ? 3 : 8)),
                  if (!_isOutOfStock && !_isPressed) BoxShadow(color: t.gold.withOpacity(0.04), blurRadius: 12, spreadRadius: 1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(flex: 62, child: _buildImageZone(image, t)),
                   Expanded(flex: 38, child: _buildInfoZone(t)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageZone(String image, SeasonTokens t) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(tag: 'product_${widget.product['id']}', child: _img(image)),
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
                  colors: [Colors.black.withOpacity(0.75), Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          if (_isOutOfStock)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.85), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.15))),
                  child: Text('OUT OF STOCK', style: GoogleFonts.dmMono(color: Colors.white.withOpacity(0.5), fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          Positioned(
            top: 9, left: 10, right: 9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isNew && !_onSale) _buildBadge('NEW', gradient: LinearGradient(colors: [t.goldLight, t.goldDark]), textColor: Colors.black)
                else if (_onSale) _buildBadge('−$_discountPct%', gradient: const LinearGradient(colors: [Color(0xFFFF6B5A), Color(0xFFFF3B30)]), textColor: Colors.white)
                else const SizedBox.shrink(),
                AnimatedBuilder(
                  animation: _heartScale,
                  builder: (_, __) => Transform.scale(
                    scale: _heartScale.value,
                    child: GestureDetector(
                      onTap: _toggleWish,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: t.bg.withOpacity(0.82), shape: BoxShape.circle, border: Border.all(color: _inWish ? SeasonTokens.red.withOpacity(0.4) : t.border, width: 1)),
                        child: Icon(_inWish ? Icons.favorite_rounded : Icons.favorite_outline_rounded, size: 15, color: _inWish ? SeasonTokens.red : t.gold.withOpacity(0.7)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 9, left: 10, right: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: t.bg.withOpacity(0.88), borderRadius: BorderRadius.circular(20), border: Border.all(color: t.gold.withOpacity(0.22), width: 1)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_onSale) ...[
                        Text('\$${_originalPrice!.toStringAsFixed(0)}', style: GoogleFonts.dmMono(color: t.gold.withOpacity(0.35), fontSize: 9, decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 4),
                      ],
                      Text('\$${_price.toStringAsFixed(0)}', style: GoogleFonts.cormorantGaramond(color: t.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                if (!_isOutOfStock)
                  AnimatedBuilder(
                    animation: _cartCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _cartScale.value,
                      child: GestureDetector(
                        onTap: _quickAddToCart,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _addedToCart ? [const Color(0xFF30D158), const Color(0xFF25B44A)] : [t.goldLight, t.goldDark]),
                            boxShadow: [BoxShadow(color: (_addedToCart ? const Color(0xFF30D158) : t.gold).withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Icon(_addedToCart ? Icons.check_rounded : Icons.add_rounded, size: 15, color: Colors.black),
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
          Expanded(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.cormorantGaramond(color: _isOutOfStock ? t.text.withOpacity(0.4) : t.text, fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.2))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 12, color: t.gold),
              const SizedBox(width: 3),
              Text(rating.toStringAsFixed(1), style: GoogleFonts.dmMono(color: t.gold.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
              const SizedBox(width: 3),
              Flexible(child: Text('(${reviewCount > 999 ? '999+' : reviewCount})', overflow: TextOverflow.ellipsis, style: GoogleFonts.dmMono(color: t.subtext, fontSize: 10))),
              const Spacer(),
              if (colors.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(colors.length.clamp(0, 4), (i) => GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = i),
                      child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 9, height: 9, margin: const EdgeInsets.only(left: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i], border: Border.all(color: _selectedColorIndex == i ? t.gold.withOpacity(0.7) : Colors.white.withOpacity(0.15), width: 1.5))),
                    )),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, {required Gradient gradient, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Text(label, style: GoogleFonts.dmMono(color: textColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.8)),
    );
  }
}
