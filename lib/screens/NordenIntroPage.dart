import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../services/api_service.dart';
import 'login&sgin in/login.dart';
import 'home_page.dart';
import '../services/backend_auth_service.dart';

class NordenIntroPage extends StatefulWidget {
  const NordenIntroPage({Key? key}) : super(key: key);

  @override
  State<NordenIntroPage> createState() => _NordenIntroPageState();
}

class _NordenIntroPageState extends State<NordenIntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Animation<double> _slideAnimation = const AlwaysStoppedAnimation<double>(0.0);
  Animation<double> _scaleAnimation = const AlwaysStoppedAnimation<double>(1.0);
  final BackendAuthService _authService = BackendAuthService();
  bool _isLoadingGuest = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isLoadingGuest = true);
    HapticFeedback.mediumImpact();

    try {
      await _authService.guestLogin();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NordenHomePage()),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        if (e.code == 'NETWORK_ERROR') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NordenHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _authService.getErrorMessage(e),
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFFF3B30),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NordenHomePage()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGuest = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0A0A),
                        const Color(
                          0xFF1A1A1A,
                        ).withOpacity(_fadeAnimation.value),
                        const Color(0xFF0F0F0F),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Large background text "NOR DEN"
          Positioned(
            left: -20,
            top: size.height * 0.15,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.08,
                  child: Text(
                    'NOR\nDEN',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: size.width * 0.45,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: -4,
                    ),
                  ),
                );
              },
            ),
          ),

          // Full-bleed hero image background (no frame)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Image.asset(
                    'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          // Bottom content area
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0A0A0A).withOpacity(0.8),
                            const Color(0xFF0A0A0A),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 60, 28, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Main tagline
                              Text(
                                'Elevate Your',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Style ',
                                    style: GoogleFonts.playfairDisplay(
                                      color: const Color(0xFFD4AF37),
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    'Game',
                                    style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Subtitle
                              Text(
                                'Discover curated collections and timeless pieces crafted exclusively for you.',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 15,
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Buttons
                              Row(
                                children: [
                                  // Get Started slide-to-act button
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        SlideAction(
                                          height: 60,
                                          borderRadius: 30,
                                          elevation: 0,
                                          innerColor: const Color(0xFF1A1A1A),
                                          outerColor: const Color(0xFF0A0A0A),
                                          sliderButtonIconPadding: 0,
                                          sliderButtonIcon: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Color(0xFFD4AF37),
                                            size: 24,
                                          ),
                                          text: 'Swipe to Get Started',
                                          textStyle: GoogleFonts.inter(
                                            color: const Color(0xFFD4AF37),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                          onSubmit: () async {
                                            HapticFeedback.mediumImpact();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const NordenLoginPage(),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '← Swipe to continue',
                                          style: GoogleFonts.inter(
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Guest button
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.15),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoadingGuest
                                          ? null
                                          : _continueAsGuest,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withOpacity(0.05),
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                      ),
                                      child: _isLoadingGuest
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Guest',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
