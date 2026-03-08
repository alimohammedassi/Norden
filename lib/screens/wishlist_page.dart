import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/wishlist_service.dart';
import '../models/wishlist_item.dart';
import '../config/app_theme.dart';

/// Dedicated Wishlist screen — animated, luxury dark theme
class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with TickerProviderStateMixin {
  final WishlistService _wishlist = WishlistService();
  late AnimationController _entranceCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _shimmerAnim;

  // Always use Winter tokens on Wishlist page (or you could inherit from parent)
  final SeasonTokens _t = AppTheme.winterTokens;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shimmerCtrl = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat();

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.1, 0.9, curve: Curves.easeOutQuart),
          ),
        );
    _shimmerAnim = Tween<double>(begin: -2.0, end: 2.0).animate(_shimmerCtrl);

    _entranceCtrl.forward();
    _wishlist.addListener(_onWishChanged);
    _wishlist.loadWishlist();
  }

  @override
  void dispose() {
    _wishlist.removeListener(_onWishChanged);
    _entranceCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onWishChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final items = _wishlist.wishlistItems;

    return Scaffold(
      backgroundColor: t.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.bg, t.surface, t.surface2, t.bg],
            stops: const [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header
              FadeTransition(opacity: _fadeAnim, child: _buildHeader(t)),

              // ── Content
              Expanded(
                child: items.isEmpty
                    ? SlideTransition(
                        position: _slideAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: _buildEmpty(t),
                        ),
                      )
                    : SlideTransition(
                        position: _slideAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: _buildGrid(items, t),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SeasonTokens t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back button
          _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
            tokens: t,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: _shimmerAnim,
              builder: (_, __) => ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [t.gold, t.goldLight, t.gold],
                  stops: [
                    (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
                    _shimmerAnim.value.clamp(0.0, 1.0),
                    (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WISHLIST',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'Your curated selection',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 12,
                        color: t.gold.withOpacity(0.7),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_wishlist.wishlistItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(color: t.border),
              ),
              child: Text(
                '${_wishlist.wishlistItems.length} items',
                style: GoogleFonts.cormorantGaramond(
                  color: t.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(SeasonTokens t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.surface,
              border: Border.all(color: t.gold.withOpacity(0.2), width: 2),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: t.gold.withOpacity(0.5),
              size: 58,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'YOUR WISHLIST IS EMPTY',
            style: GoogleFonts.cormorantGaramond(
              color: t.gold,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Save the pieces you love for later',
            style: GoogleFonts.inter(color: t.subtext, fontSize: 14),
          ),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [t.goldLight, t.goldDark]),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: t.gold.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'EXPLORE COLLECTION',
                style: GoogleFonts.cormorantGaramond(
                  color: t.bg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<WishlistItem> items, SeasonTokens t) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return _WishlistCard(
          item: item,
          tokens: t,
          onRemove: () async {
            HapticFeedback.lightImpact();
            await _wishlist.removeFromWishlist(item.productId);
          },
          onTap: () {},
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
//  WISHLIST CARD
// ─────────────────────────────────────────────────────────
class _WishlistCard extends StatefulWidget {
  final WishlistItem item;
  final SeasonTokens tokens;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  const _WishlistCard({
    required this.item,
    required this.tokens,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _removeCtrl;
  late Animation<double> _removeFade;
  late Animation<Offset> _removeSlide;

  @override
  void initState() {
    super.initState();
    _removeCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _removeFade = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _removeCtrl, curve: Curves.easeIn));
    _removeSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(parent: _removeCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _removeCtrl.dispose();
    super.dispose();
  }

  Future<void> _animateRemove() async {
    await _removeCtrl.forward();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final item = widget.item;
    final image = item.imageUrl.isNotEmpty
        ? item.imageUrl
        : 'assets/images/Double-breasted_blazer.jpg';
    final name = item.productName;
    final price = item.price.toStringAsFixed(0);

    return SlideTransition(
      position: _removeSlide,
      child: FadeTransition(
        opacity: _removeFade,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: t.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 65,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: image.startsWith('http')
                              ? Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: t.surface2),
                                )
                              : Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: t.surface2),
                                ),
                        ),
                      ),
                      // Gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Remove button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _animateRemove,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: t.bg.withOpacity(0.9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SeasonTokens.red.withOpacity(0.4),
                              ),
                            ),
                            child: Icon(
                              Icons.favorite,
                              size: 16,
                              color: SeasonTokens.red,
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
                            border: Border.all(color: t.gold.withOpacity(0.25)),
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
                // Info
                Expanded(
                  flex: 35,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            color: t.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.star_rounded, size: 13, color: t.gold),
                            const SizedBox(width: 2),
                            Text(
                              '4.8',
                              style: GoogleFonts.cormorantGaramond(
                                color: t.gold.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: t.gold.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 11,
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  CIRCLE BUTTON helper
// ─────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final SeasonTokens tokens;
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.surface,
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Icon(icon, color: t.gold.withOpacity(0.8), size: 18),
        ),
      ),
    );
  }
}
