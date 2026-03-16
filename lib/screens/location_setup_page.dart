import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/google_maps_picker.dart';
import '../services/location_service.dart';
import '../services/address_service.dart';
import '../services/backend_auth_service.dart';
import 'main_screen.dart';
import '../providers/season_provider.dart';
import '../config/app_theme.dart';

class LocationSetupPage extends StatefulWidget {
  const LocationSetupPage({Key? key}) : super(key: key);

  @override
  State<LocationSetupPage> createState() => _LocationSetupPageState();
}

class _LocationSetupPageState extends State<LocationSetupPage>
    with SingleTickerProviderStateMixin {
  SeasonTokens get t => SeasonScope.of(context).tokens;
  final LocationService _locationService = LocationService();
  final AddressService _addressService = AddressService();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToMain() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _processMapResult(Map<String, dynamic> result) async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    String city = 'Unknown';
    String country = 'Unknown';

    try {
      final marks = await placemarkFromCoordinates(
        result['latitude'],
        result['longitude'],
      );
      if (marks.isNotEmpty) {
        city = marks[0].locality ?? marks[0].administrativeArea ?? 'Unknown';
        country = marks[0].country ?? 'Unknown';
      }
    } catch (_) {}

    // Get user's name from auth service (they already registered)
    final authService = BackendAuthService();
    final userName = authService.currentUser?['displayName'] ??
        authService.currentUser?['email'] ??
        'User';

    try {
      // Save address locally
      await _addressService.addAddress(
        label: 'Home',
        name: userName,
        phone: '',
        street: 'Selected via Map',
        city: city,
        country: country,
        isDefault: true,
      );

      // Sync location to backend
      await _locationService.syncLocationToBackend(
        latitude: result['latitude'],
        longitude: result['longitude'],
        city: city,
        country: country,
      );
    } catch (e) {
      debugPrint('Location save error: $e');
      // Even if backend fails, save locally and proceed
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _navigateToMain();
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() => _isLoading = false);
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleMapsPicker(
              initialLabel: 'Home',
              initialLatitude: position.latitude,
              initialLongitude: position.longitude,
            ),
          ),
        );
        if (result != null && mounted) {
          await _processMapResult(result);
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not get location. Try entering manually.',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _enterManually() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const GoogleMapsPicker(initialLabel: 'Home'),
      ),
    );
    if (result != null && mounted) {
      await _processMapResult(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Gold radial glow background
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.08),
                    Colors.transparent,
                  ],
                  radius: 1.0,
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // Icon Map
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A1A1A),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          size: 44,
                          color: Color(0xFFD4AF37),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Title
                      Text(
                        'Set Your Location',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Personalize your delivery estimates\nand discover nearby stores.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Use Current Location button
                      _PrimaryButton(
                        icon: Icons.gps_fixed_rounded,
                        label: 'Use Current Location',
                        isLoading: _isLoading,
                        onTap: _isLoading ? null : _useCurrentLocation,
                      ),

                      const SizedBox(height: 16),

                      // Enter Manually button
                      _SecondaryButton(
                        icon: Icons.map_outlined,
                        label: 'Pick on Map',
                        isLoading: false,
                        onTap: _isLoading ? null : _enterManually,
                      ),

                      const SizedBox(height: 32),

                      // Skip
                      TextButton(
                        onPressed: _isLoading ? null : _navigateToMain,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.45),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Full-screen loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Reusable Buttons ───────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.5,
                ),
              )
            : Icon(icon, size: 20, color: Colors.black),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          disabledBackgroundColor: const Color(0xFFD4AF37).withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: Colors.white.withOpacity(0.8)),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1.2,
          ),
          backgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
