import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'login&sgin in/login.dart';
import 'home_page.dart';
import '../services/backend_auth_service.dart';

// This is your separate intro page - import this into your main.dart
class NordenIntroPage extends StatefulWidget {
  const NordenIntroPage({Key? key}) : super(key: key);

  @override
  State<NordenIntroPage> createState() => _NordenIntroPageState();
}

class _NordenIntroPageState extends State<NordenIntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final BackendAuthService _authService = BackendAuthService();
  bool _isLoadingGuest = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  /// Sign in as guest (anonymous)
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
        // If it's a network error, just continue as guest anyway
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
            ),
          );
        }
      }
    } catch (e) {
      // If any error occurs, just continue as guest
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Elegant diamond icon
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFD4AF37).withOpacity(0.15),
                                const Color(0xFFB8860B).withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.diamond_outlined,
                            size: 80,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // App name with elegant styling
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFD4AF37),
                              Color(0xFFFFF8DC),
                              Color(0xFFD4AF37),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'NORDEN',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 56,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 18,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 4),
                                  blurRadius: 15,
                                ),
                                Shadow(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Decorative line
                        Container(
                          height: 2,
                          width: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFD4AF37),
                                Color(0xFFFFF8DC),
                                Color(0xFFD4AF37),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'MAISON DE COUTURE',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFFD4AF37).withOpacity(0.8),
                            letterSpacing: 5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),

                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Categories row
                        const SizedBox(height: 45),
                        // Get Started button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                // Navigate to login page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NordenLoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFB8860B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'ENTER NORDEN',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 3,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Continue as Guest button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton(
                            onPressed: _isLoadingGuest
                                ? null
                                : _continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD4AF37),
                              side: BorderSide(
                                color: const Color(0xFFD4AF37).withOpacity(0.5),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: const Color(
                                0xFF1A1A1A,
                              ).withOpacity(0.3),
                            ),
                            child: _isLoadingGuest
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFD4AF37),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 20,
                                        color: Color(0xFFD4AF37),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'CONTINUE AS GUEST',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                          color: const Color(0xFFD4AF37),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder for your main page - replace this with your actual main page
class YourMainPage extends StatelessWidget {
  const YourMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Norden - Main Page')),
      body: Center(child: Text('Your main page content here')),
    );
  }
}
