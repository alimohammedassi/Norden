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
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Container(
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
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildProfileHeader(),
                            const SizedBox(height: 24),
                            // Guest prompt to create account
                            if (_authService.isAnonymous) ...[
                              _buildCreateAccountPrompt(),
                              const SizedBox(height: 24),
                            ],
                            _buildInfoSection(),
                            const SizedBox(height: 24),
                            _buildMenuItems(),
                            const SizedBox(height: 32),
                            _buildSignOutButton(),
                            const SizedBox(height: 24),
                          ],
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
              'PROFILE',
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

  Widget _buildProfileHeader() {
    final bool isGuest = _authService.isAnonymous;
    final String displayName = isGuest
        ? 'Guest'
        : (_currentUser?['displayName'] ?? 'Guest');
    final String email = _currentUser?['email'] ?? '';
    final String initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'G';

    return Column(
      children: [
        // Profile Picture
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _currentUser?['photoURL'] != null
              ? ClipOval(
                  child: Image.network(
                    _currentUser!['photoURL']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialsAvatar(initials);
                    },
                  ),
                )
              : _buildInitialsAvatar(initials),
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          displayName,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        // Email
        if (email.isNotEmpty)
          Text(
            email,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFD4AF37).withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCreateAccountPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.15),
            const Color(0xFFB8860B).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_border_rounded,
                color: const Color(0xFFD4AF37),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Create an Account',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Save your cart, track orders, and unlock exclusive benefits by creating a free account.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFFD4AF37).withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NordenIntroPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'CREATE ACCOUNT',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Colors.black,
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

  Widget _buildInfoSection() {
    final String provider = _getAuthProvider();
    final String memberSince = _getMemberSince();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Sign-in Method', provider),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFD4AF37).withOpacity(0.1)),
          const SizedBox(height: 16),
          _buildInfoRow('Member Since', memberSince),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFFD4AF37).withOpacity(0.5),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        if (!_authService.isAnonymous) ...[
          _buildMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
              if (result == true && mounted) {
                setState(() {
                  _currentUser = _authService.currentUser;
                });
              }
            },
          ),
          const SizedBox(height: 12),
        ],
        _buildMenuItem(
          icon: Icons.favorite_border_rounded,
          title: 'Wishlist',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: 'Order History',
          onTap: () {
            // TODO: Implement order history
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order history coming soon',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: const Color(0xFF1A1A1A),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.credit_card_rounded,
          title: 'Payment Methods',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentMethodsPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.location_on_outlined,
          title: 'Addresses',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddressesPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.headset_mic_outlined,
          title: 'Customer Service',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerServicePage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: 'About Norden',
          onTap: () {
            // TODO: Implement about page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'About Norden coming soon',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: const Color(0xFF1A1A1A),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {
            // TODO: Implement settings
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Settings coming soon',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: const Color(0xFF1A1A1A),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFD4AF37), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFFD4AF37).withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFFFF3B30).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Color(0xFFFF3B30), size: 20),
            const SizedBox(width: 8),
            Text(
              'SIGN OUT',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: const Color(0xFFFF3B30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAuthProvider() {
    if (_currentUser == null) return 'Guest';
    if (_authService.isAnonymous) return 'Anonymous';

    // TODO: Implement provider detection for backend user data
    return 'Email/Password';
  }

  String _getMemberSince() {
    // TODO: Implement member since for backend user data
    return 'Unknown';
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.inter(
            color: const Color(0xFFD4AF37).withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'SIGN OUT',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const NordenIntroPage()),
            (route) => false,
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
              backgroundColor: const Color(0xFFFF3B30),
            ),
          );
        }
      }
    }
  }
}
