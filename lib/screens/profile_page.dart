import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'NordenIntroPage.dart';
import 'profile/edit_profile_page.dart';
import 'profile/wishlist_page.dart';
import 'profile/payment_methods_page.dart';
import 'profile/addresses_page.dart';
import 'profile/customer_service_page.dart';

class ProfilePage extends StatefulWidget {
  final bool showBackButton;
  const ProfilePage({super.key, this.showBackButton = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final AuthService _authService = AuthService();
  Map<String, dynamic>? _currentUser;

  // Gold palette
  static const _gold = Color(0xFFD4AF37);
  static const _goldDeep = Color(0xFFB8860B);
  static const _goldDim = Color(0x33D4AF37);
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF141414);
  static const _surfaceHigh = Color(0xFF1C1C1C);
  static const _red = Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
          ),
        );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverHero(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatsRow(),
                    const SizedBox(height: 28),
                    if (_authService.isAnonymous) ...[
                      _buildGuestBanner(),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionLabel('ACCOUNT'),
                    const SizedBox(height: 10),
                    _buildAccountGroup(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('SUPPORT'),
                    const SizedBox(height: 10),
                    _buildSupportGroup(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('GENERAL'),
                    const SizedBox(height: 10),
                    _buildGeneralGroup(),
                    const SizedBox(height: 32),
                    _buildSignOutButton(),
                    const SizedBox(height: 8),
                    _buildVersionLabel(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sliver Hero ─────────────────────────────────────────────────────────

  Widget _buildSliverHero() {
    final bool isGuest = _authService.isAnonymous;
    final String displayName = isGuest
        ? 'Guest'
        : (_currentUser?['displayName'] ?? 'Guest');
    final String email = _currentUser?['email'] ?? '';
    final String initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'G';

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // ── Ambient background ──
          Container(
            height: 340,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF111008), _bg],
              ),
            ),
          ),
          // ── Gold radial glow ──
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Container(
              height: 340,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 0.9,
                  colors: [
                    _gold.withOpacity(_pulseAnimation.value * 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Fine grain texture overlay ──
          Container(
            height: 340,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/noise.png'),
                repeat: ImageRepeat.repeat,
                opacity: 0.04,
              ),
            ),
          ),
          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 24),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildAvatarRing(initials),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName.toUpperCase(),
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: _gold,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.dmMono(
                      fontSize: 12,
                      color: _gold.withOpacity(0.45),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _buildMemberBadge(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          if (widget.showBackButton)
            _iconBtn(
              Icons.arrow_back_ios_new_rounded,
              () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          _iconBtn(Icons.notifications_none_rounded, () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
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
            color: _gold.withOpacity(0.07),
            border: Border.all(color: _gold.withOpacity(0.15)),
          ),
          child: Icon(icon, color: _gold, size: 20),
        ),
      ),
    );
  }

  Widget _buildAvatarRing(String initials) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // outer decorative ring
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [_gold, _goldDeep, Colors.transparent, _gold],
              stops: [0.0, 0.3, 0.65, 1.0],
            ),
          ),
        ),
        // gap ring
        Container(
          width: 112,
          height: 112,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: _bg),
        ),
        // avatar
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F1B0A), Color(0xFF2A2308)],
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: _currentUser?['photoURL'] != null
              ? ClipOval(
                  child: Image.network(
                    _currentUser!['photoURL']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialsWidget(initials),
                  ),
                )
              : _initialsWidget(initials),
        ),
        // edit badge
        if (!_authService.isAnonymous)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                if (result == true && mounted) {
                  setState(() => _currentUser = _authService.currentUser);
                }
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_gold, _goldDeep]),
                  border: Border.all(color: _bg, width: 2),
                  boxShadow: [
                    BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.black, size: 13),
              ),
            ),
          ),
      ],
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: _gold,
        ),
      ),
    );
  }

  Widget _buildMemberBadge() {
    final label = _authService.isAnonymous ? 'GUEST' : 'NORDEN MEMBER';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.35)),
        color: _gold.withOpacity(0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_outlined, color: _gold, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmMono(
              fontSize: 11,
              color: _gold,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: _surfaceHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _statCell('0', 'Orders'),
          _statDivider(),
          _statCell('0', 'Wishlist'),
          _statDivider(),
          _statCell('—', 'Points'),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _gold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmMono(
              fontSize: 10,
              color: _gold.withOpacity(0.45),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 36, color: _gold.withOpacity(0.15));
  }

  // ─── Guest Banner ─────────────────────────────────────────────────────────

  Widget _buildGuestBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gold.withOpacity(0.12), _goldDeep.withOpacity(0.06)],
        ),
        border: Border.all(color: _gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: _gold, size: 22),
              const SizedBox(width: 10),
              Text(
                'Unlock Full Access',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Create a free account to save your cart, track orders, and access exclusive member benefits.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _gold.withOpacity(0.6),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_gold, _goldDeep]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NordenIntroPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'CREATE ACCOUNT',
                  style: GoogleFonts.dmMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Helpers ──────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 12, color: _gold),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.dmMono(
            fontSize: 10,
            color: _gold.withOpacity(0.5),
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountGroup() {
    return _buildMenuGroup([
      if (!_authService.isAnonymous)
        _MenuEntry(
          icon: Icons.person_outline_rounded,
          label: 'Edit Profile',
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            );
            if (result == true && mounted) {
              setState(() => _currentUser = _authService.currentUser);
            }
          },
        ),
      _MenuEntry(
        icon: Icons.favorite_border_rounded,
        label: 'Wishlist',
        badge: '0',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WishlistPage()),
        ),
      ),
      _MenuEntry(
        icon: Icons.receipt_long_outlined,
        label: 'Order History',
        onTap: () => _comingSoon('Order history'),
      ),
      _MenuEntry(
        icon: Icons.credit_card_rounded,
        label: 'Payment Methods',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
        ),
      ),
      _MenuEntry(
        icon: Icons.location_on_outlined,
        label: 'Addresses',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddressesPage()),
        ),
      ),
    ]);
  }

  Widget _buildSupportGroup() {
    return _buildMenuGroup([
      _MenuEntry(
        icon: Icons.headset_mic_outlined,
        label: 'Customer Service',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerServicePage()),
        ),
      ),
      _MenuEntry(
        icon: Icons.info_outline_rounded,
        label: 'About Norden',
        onTap: () => _comingSoon('About Norden'),
      ),
    ]);
  }

  Widget _buildGeneralGroup() {
    return _buildMenuGroup([
      _MenuEntry(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () => _comingSoon('Settings'),
      ),
      _MenuEntry(
        icon: Icons.shield_outlined,
        label: 'Privacy Policy',
        onTap: () => _comingSoon('Privacy Policy'),
      ),
    ]);
  }

  Widget _buildMenuGroup(List<_MenuEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: _surfaceHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(entries.length * 2 - 1, (i) {
            if (i.isOdd) {
              return Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: _gold.withOpacity(0.07),
              );
            }
            return _buildTile(entries[i ~/ 2]);
          }),
        ),
      ),
    );
  }

  Widget _buildTile(_MenuEntry entry) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          entry.onTap();
        },
        splashColor: _gold.withOpacity(0.06),
        highlightColor: _gold.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _gold.withOpacity(0.08),
                  border: Border.all(color: _gold.withOpacity(0.15)),
                ),
                child: Icon(entry.icon, color: _gold, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  entry.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _gold.withOpacity(0.88),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (entry.badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _gold.withOpacity(0.2)),
                  ),
                  child: Text(
                    entry.badge!,
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      color: _gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _gold.withOpacity(0.25),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Widget _buildSignOutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _signOut,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _red.withOpacity(0.35)),
            color: _red.withOpacity(0.06),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: _red, size: 18),
              const SizedBox(width: 10),
              Text(
                'SIGN OUT',
                style: GoogleFonts.dmMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: _red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionLabel() {
    return Center(
      child: Text(
        'NORDEN v1.0.0',
        style: GoogleFonts.dmMono(
          fontSize: 10,
          color: _gold.withOpacity(0.2),
          letterSpacing: 2,
        ),
      ),
    );
  }

  // ─── Utils ────────────────────────────────────────────────────────────────

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.schedule_rounded, color: _gold, size: 16),
            const SizedBox(width: 10),
            Text(
              '$feature — coming soon',
              style: GoogleFonts.inter(
                color: _gold.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _gold.withOpacity(0.2)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _signOut() async {
    HapticFeedback.mediumImpact();
    final shouldSignOut = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _gold.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
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
                      color: _red.withOpacity(0.1),
                      border: Border.all(color: _red.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: _red,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Sign Out',
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
                'You will be returned to the welcome screen. Are you sure you want to continue?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _gold.withOpacity(0.55),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
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
                          fontSize: 12,
                          color: _gold.withOpacity(0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _red.withOpacity(0.4)),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'SIGN OUT',
                          style: GoogleFonts.dmMono(
                            fontSize: 12,
                            color: _red,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
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

    if (shouldSignOut == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const NordenIntroPage()),
            (_) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error signing out. Please try again.',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: _red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _MenuEntry {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });
}
