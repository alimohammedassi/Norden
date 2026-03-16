import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'checkout_page.dart';
import 'main_screen.dart';

/// Shopping cart page — Norden luxury dark theme
class CartPage extends StatefulWidget {
  final bool showBackButton;
  const CartPage({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _entryController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _shimmer;
  late Animation<double> _pulse;

  final CartService _cartService = CartService();
  final TextEditingController _promoController = TextEditingController();
  bool _promoApplied = false;
  bool _promoExpanded = false;
  String? _promoError;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const _gold = Color(0xFFD4AF37);
  static const _goldDeep = Color(0xFFB8860B);
  static const _goldPale = Color(0xFFFFF0A0);
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF141414);
  static const _surfaceHigh = Color(0xFF1C1C1C);
  static const _red = Color(0xFFFF3B30);
  static const _green = Color(0xFF30D158);

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.1, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    _shimmer = _shimmerController;
    _pulse = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
    _cartService.addListener(_onCartChanged);
    _cartService.initialize();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _entryController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _promoController.dispose();
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  // ── Checkout ──────────────────────────────────────────────────────────────
  void _checkout() {
    HapticFeedback.mediumImpact();
    if (_cartService.items.isEmpty) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const CheckoutPage(),
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
      ),
    );
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    HapticFeedback.lightImpact();
    if (code == 'NORDEN10') {
      setState(() {
        _promoApplied = true;
        _promoError = null;
        _promoExpanded = false;
      });
      HapticFeedback.mediumImpact();
    } else {
      setState(() {
        _promoApplied = false;
        _promoError = 'Invalid promo code';
      });
    }
  }

  double get _discount => _promoApplied ? _cartService.subtotal * 0.10 : 0;

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Ambient gold glow at top
          _buildAmbientGlow(),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _cartService.items.isEmpty
                        ? _buildEmptyCart()
                        : _buildCartList(),
                  ),
                  if (_cartService.items.isNotEmpty) _buildBottomSheet(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ambient glow ──────────────────────────────────────────────────────────
  Widget _buildAmbientGlow() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Positioned(
        top: -80,
        left: 0,
        right: 0,
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              radius: 0.9,
              colors: [
                _gold.withOpacity(_pulse.value * 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SlideTransition(
      position: _slideUp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            if (widget.showBackButton)
              _circleBtn(
                Icons.arrow_back_ios_new_rounded,
                () => Navigator.pop(context),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerText(
                    'CART',
                    GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                  if (_cartService.items.isNotEmpty)
                    Text(
                      '${_cartService.itemCount} '
                      '${_cartService.itemCount == 1 ? 'item' : 'items'} selected',
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        color: _gold.withOpacity(0.45),
                        letterSpacing: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            if (_cartService.items.isNotEmpty)
              _circleBtn(
                Icons.delete_sweep_outlined,
                () {
                  HapticFeedback.lightImpact();
                  _showClearCartDialog();
                },
                color: _red.withOpacity(0.7),
                bgOpacity: 0.08,
                borderColor: _red.withOpacity(0.25),
              ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(
    IconData icon,
    VoidCallback onTap, {
    Color color = _gold,
    double bgOpacity = 0.07,
    Color? borderColor,
  }) {
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
            color: color.withOpacity(bgOpacity),
            border: Border.all(color: borderColor ?? color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _shimmerText(String text, TextStyle style) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: const [_gold, _goldPale, _gold],
          stops: [
            (_shimmer.value - 0.3).clamp(0.0, 1.0),
            _shimmer.value.clamp(0.0, 1.0),
            (_shimmer.value + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: Text(text, style: style),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return SlideTransition(
      position: _slideUp,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative ring with icon
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _gold.withOpacity(_pulse.value * 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _surfaceHigh,
                    border: Border.all(
                      color: _gold.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: _gold.withOpacity(0.45),
                    size: 46,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'YOUR CART IS EMPTY',
              style: GoogleFonts.cormorantGaramond(
                color: _gold,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Curate your luxury collection',
              style: GoogleFonts.dmMono(
                color: _gold.withOpacity(0.4),
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 36),
            _goldButton(
              label: 'EXPLORE COLLECTION',
              icon: Icons.arrow_forward_rounded,
              onTap: () {
                if (widget.showBackButton) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Cart List ─────────────────────────────────────────────────────────────
  Widget _buildCartList() {
    return SlideTransition(
      position: _slideUp,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _cartService.items.length,
        itemBuilder: (context, index) {
          final item = _cartService.items[index];
          return _AnimatedCartItem(
            key: ValueKey(item.id),
            index: index,
            item: item,
            onRemove: () => _showRemoveItemDialog(item),
            onIncrement: () {
              HapticFeedback.lightImpact();
              if (item.quantity < 99) {
                _cartService.updateQuantity(item.id, item.quantity + 1);
              }
            },
            onDecrement: () {
              HapticFeedback.lightImpact();
              if (item.quantity > 1) {
                _cartService.updateQuantity(item.id, item.quantity - 1);
              } else {
                _showRemoveItemDialog(item);
              }
            },
          );
        },
      ),
    );
  }

  // ── Bottom Sheet ──────────────────────────────────────────────────────────
  Widget _buildBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: _gold.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: _gold.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag pill
          Center(
            child: Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Promo Code
          _buildPromoSection(),
          const SizedBox(height: 20),

          // Summary
          _buildSummaryLine('Subtotal', _cartService.subtotal),
          const SizedBox(height: 10),
          _buildSummaryLine('Tax (10%)', _cartService.tax),
          const SizedBox(height: 10),
          _buildSummaryLine('Shipping', _cartService.shipping),
          if (_promoApplied) ...[
            const SizedBox(height: 10),
            _buildSummaryLine(
              'Promo (NORDEN10)',
              -_discount,
              valueColor: _green,
            ),
          ],
          const SizedBox(height: 16),

          // Hairline divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _gold.withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: GoogleFonts.dmMono(
                      color: _gold.withOpacity(0.5),
                      fontSize: 10,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'incl. all taxes',
                    style: GoogleFonts.dmMono(
                      color: _gold.withOpacity(0.28),
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              _shimmerText(
                '\$${(_cartService.total - _discount).toStringAsFixed(2)}',
                GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Checkout CTA
          _goldButton(
            label: 'PROCEED TO CHECKOUT',
            icon: Icons.lock_outline_rounded,
            onTap: _checkout,
            height: 58,
            fontSize: 14,
          ),

          const SizedBox(height: 12),

          // Trust badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _trustBadge(Icons.verified_outlined, 'Secure'),
              _trustBadge(Icons.local_shipping_outlined, 'Free Returns'),
              _trustBadge(Icons.support_agent_outlined, '24/7 Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _promoExpanded = !_promoExpanded);
          },
          child: Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: _promoApplied ? _green : _gold.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _promoApplied ? 'Promo applied ✓' : 'Add promo code',
                style: GoogleFonts.dmMono(
                  color: _promoApplied ? _green : _gold.withOpacity(0.6),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (!_promoApplied)
                Icon(
                  _promoExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _gold.withOpacity(0.4),
                  size: 18,
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: _promoExpanded && !_promoApplied
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: _surfaceHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _promoError != null
                                  ? _red.withOpacity(0.5)
                                  : _gold.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _promoController,
                            textCapitalization: TextCapitalization.characters,
                            style: GoogleFonts.dmMono(
                              color: _gold,
                              fontSize: 13,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'ENTER CODE',
                              hintStyle: GoogleFonts.dmMono(
                                color: _gold.withOpacity(0.25),
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _applyPromo,
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_gold, _goldDeep],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'APPLY',
                              style: GoogleFonts.dmMono(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (_promoError != null && !_promoApplied && _promoExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _promoError!,
              style: GoogleFonts.dmMono(
                color: _red.withOpacity(0.8),
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, double amount, {Color? valueColor}) {
    final isNeg = amount < 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: _gold.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '${isNeg ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: GoogleFonts.dmMono(
            color: valueColor ?? _gold.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _trustBadge(IconData icon, String label) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _gold.withOpacity(0.3), size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmMono(
              color: _gold.withOpacity(0.3),
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    double height = 54,
    double fontSize = 13,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_gold, _goldDeep]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black, size: 18),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.dmMono(
                color: Colors.black,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showRemoveItemDialog(CartItem item) {
    _luxDialog(
      icon: Icons.delete_outline_rounded,
      iconColor: _red,
      title: 'Remove Item',
      body: 'Remove "${item.productName}" from your cart?',
      confirmLabel: 'REMOVE',
      confirmColor: _red,
      onConfirm: () {
        _cartService.removeItem(item.id);
        HapticFeedback.mediumImpact();
      },
    );
  }

  void _showClearCartDialog() {
    _luxDialog(
      icon: Icons.delete_sweep_outlined,
      iconColor: _red,
      title: 'Clear Cart',
      body: 'Remove all ${_cartService.itemCount} items from your cart?',
      confirmLabel: 'CLEAR ALL',
      confirmColor: _red,
      onConfirm: () {
        _cartService.clear();
        HapticFeedback.mediumImpact();
      },
    );
  }

  void _luxDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _gold.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor.withOpacity(0.1),
                      border: Border.all(color: iconColor.withOpacity(0.3)),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                body,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _gold.withOpacity(0.5),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: _gold.withOpacity(0.2)),
                        ),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.dmMono(
                          fontSize: 11,
                          color: _gold.withOpacity(0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: confirmColor.withOpacity(0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: confirmColor.withOpacity(0.35),
                          ),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: GoogleFonts.dmMono(
                          fontSize: 11,
                          color: confirmColor,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Animated Cart Item — staggered reveal + swipe-to-dismiss
// ══════════════════════════════════════════════════════════════════════════════

class _AnimatedCartItem extends StatefulWidget {
  final int index;
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _AnimatedCartItem({
    required Key key,
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  State<_AnimatedCartItem> createState() => _AnimatedCartItemState();
}

class _AnimatedCartItemState extends State<_AnimatedCartItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const _gold = Color(0xFFD4AF37);
  static const _goldDeep = Color(0xFFB8860B);
  static const _surface = Color(0xFF1A1A1A);
  static const _red = Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      duration: Duration(milliseconds: 450 + widget.index * 80),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    // Stagger
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: ValueKey(widget.item.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            widget.onRemove();
            return false; // We handle removal ourselves
          },
          background: _dismissBackground(),
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _dismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _red.withOpacity(0.3)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_outline_rounded, color: _red, size: 22),
          const SizedBox(height: 4),
          Text(
            'REMOVE',
            style: GoogleFonts.dmMono(
              color: _red,
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product image ──
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: SizedBox(
              width: 106,
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF222222),
                      child: Icon(
                        Icons.image_outlined,
                        color: _gold.withOpacity(0.2),
                        size: 36,
                      ),
                    ),
                  ),
                  // subtle gradient overlay on image
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Details ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + delete
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: GoogleFonts.cormorantGaramond(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: widget.onRemove,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _red.withOpacity(0.08),
                            border: Border.all(color: _red.withOpacity(0.22)),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: _red.withOpacity(0.7),
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Color + Size chips
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      _chip(item.selectedColor),
                      _chip('Size ${item.selectedSize}'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Price + Qty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.cormorantGaramond(
                              color: _gold,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (item.quantity > 1)
                            Text(
                              '\$${item.price.toStringAsFixed(2)} each',
                              style: GoogleFonts.dmMono(
                                color: _gold.withOpacity(0.35),
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
                      _buildQtyControl(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gold.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmMono(
          color: _gold.withOpacity(0.65),
          fontSize: 9,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildQtyControl() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove_rounded, widget.onDecrement),
          Container(
            width: 32,
            height: 36,
            alignment: Alignment.center,
            child: Text(
              '${widget.item.quantity}',
              style: GoogleFonts.dmMono(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _qtyBtn(Icons.add_rounded, widget.onIncrement),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: _gold.withOpacity(0.8), size: 16),
        ),
      ),
    );
  }
}
