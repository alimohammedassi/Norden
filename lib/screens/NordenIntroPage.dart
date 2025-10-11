import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login&sgin in/login.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Pure black
              Color(0xFF0A0E1A), // Very dark navy
              Color(0xFF0D1B2A), // Dark blue-black
              Color(0xFF1B263B), // Deep navy
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [Color(0xFF1E3A5F).withOpacity(0.2), Colors.transparent],
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
                        // Elegant snowflake icon
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2E5C8A).withOpacity(0.3),
                                Color(0xFF1E3A5F).withOpacity(0.2),
                              ],
                            ),
                            border: Border.all(
                              color: Color(0xFF4A7BA7).withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2E5C8A).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.ac_unit_rounded,
                            size: 70,
                            color: Color(0xFF5E9FD8),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // App name with elegant styling
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFB8D4E8),
                              Color(0xFF5E9FD8),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'NORDEN',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 52,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: 16,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF2E5C8A),
                                  offset: Offset(0, 3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Decorative line
                        Container(
                          height: 1.5,
                          width: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF5E9FD8),
                                Color(0xFF4A7BA7),
                                Color(0xFF5E9FD8),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF5E9FD8).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Premium Winter Collection',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Color(0xFFB8D4E8),
                            letterSpacing: 4,
                            fontWeight: FontWeight.w300,
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
                                color: Color(0xFF5E9FD8).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
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
                                backgroundColor: Color(0xFF5E9FD8),
                                foregroundColor: Color(0xFF0A0E1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'EXPLORE COLLECTION',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.5,
                                ),
                              ),
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
