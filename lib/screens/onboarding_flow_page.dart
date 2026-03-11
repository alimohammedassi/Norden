import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/onboarding_page.dart';
import '../services/onboarding_service.dart';
import 'NordenIntroPage.dart';
import '../providers/season_provider.dart';
import '../config/app_theme.dart';

class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({Key? key}) : super(key: key);

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  SeasonTokens get t => SeasonScope.of(context).tokens;
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();

  List<OnboardingPage> _pages = [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPages() async {
    try {
      final pages = await _onboardingService.getPages();
      if (mounted) {
        setState(() {
          _pages = pages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pages = OnboardingPage.fallback;
          _isLoading = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NordenIntroPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      // Fallback local image if none is provided
      return Image.asset(
        'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(color: t.gold),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fallback on error
        return Image.asset(
          'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        backgroundColor: t.bg,
        body: Center(
          child: CircularProgressIndicator(color: t.gold),
        ),
      );
    }

    if (_pages.isEmpty) {
      // Emergency fallback if even fallback fails
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finishOnboarding();
      });
      return Scaffold(backgroundColor: t.bg);
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          // Background PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              HapticFeedback.selectionClick();
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(page.imageUrl),
                  // Dark gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          t.bg.withOpacity(0.5),
                          t.bg.withOpacity(0.9),
                          t.bg,
                        ],
                        stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 40.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            page.headline,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.description,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(
                            height: 120,
                          ), // Space for bottom controls
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Right Skip Button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: _finishOnboarding,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                           padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls (Dots and Next/Start Button)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(right: 8),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? t.gold
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next / Start Button
                    FloatingActionButton(
                      onPressed: _nextPage,
                      backgroundColor: t.gold,
                      child: Icon(
                        _currentPage == _pages.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: t.bg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
