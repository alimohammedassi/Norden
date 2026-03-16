import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import 'screens/onboarding_flow_page.dart';
import 'screens/admin/admin_dashboard.dart';
import 'services/backend_auth_service.dart';
import 'services/cart_service.dart';
import 'services/wishlist_service.dart';
import 'services/token_manager.dart';
import 'providers/season_provider.dart';
import 'screens/main_screen.dart';
import 'screens/location_setup_page.dart';
import 'services/address_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize backend auth service with timeout
  final authService = BackendAuthService();
  await authService.initWithTimeout();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()..initialize()),
        ChangeNotifierProvider(create: (_) => WishlistService()..initialize()),
      ],
      child: SeasonScope(
        provider: SeasonProvider(),
        child: const NordenApp(),
      ),
    ),
  );
}

class NordenApp extends StatelessWidget {
  const NordenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final season = SeasonScope.of(context);
    final tokens = season.tokens;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Norden',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFD4AF37, {
          50: Color(0xFFFDF8E1),
          100: Color(0xFFF9EBB3),
          200: Color(0xFFF5DD81),
          300: Color(0xFFF1CF4F),
          400: Color(0xFFEEC12D),
          500: Color(0xFFD4AF37),
          600: Color(0xFFB8860B),
          700: Color(0xFF9C6B00),
          800: Color(0xFF805000),
          900: Color(0xFF643500),
        }),
        primaryColor: tokens.bg,
        scaffoldBackgroundColor: tokens.bg,
        textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
          bodyLarge: GoogleFonts.inter(color: tokens.text),
          bodyMedium: GoogleFonts.inter(color: tokens.text),
          displayLarge: GoogleFonts.playfairDisplay(color: tokens.text),
          displayMedium: GoogleFonts.playfairDisplay(color: tokens.text),
          displaySmall: GoogleFonts.playfairDisplay(color: tokens.text),
          headlineLarge: GoogleFonts.playfairDisplay(color: tokens.text),
          headlineMedium: GoogleFonts.playfairDisplay(color: tokens.text),
          headlineSmall: GoogleFonts.playfairDisplay(color: tokens.text),
        ),
        colorScheme: season.isSummer
            ? ColorScheme.light(
                primary: tokens.gold,
                secondary: tokens.goldDark,
                surface: tokens.surface,
                background: tokens.bg,
                onPrimary: tokens.bg,
                onSecondary: tokens.bg,
                onSurface: tokens.text,
                onBackground: tokens.text,
              )
            : ColorScheme.dark(
                primary: tokens.gold,
                secondary: tokens.goldDark,
                surface: tokens.surface,
                background: tokens.bg,
                onPrimary: tokens.bg,
                onSecondary: tokens.bg,
                onSurface: tokens.text,
                onBackground: tokens.text,
              ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: tokens.gold,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: tokens.gold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.gold,
            foregroundColor: tokens.bg,
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: tokens.surface.withOpacity(0.6),
          elevation: 8,
          shadowColor: tokens.gold.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tokens.gold.withOpacity(0.15), width: 1),
          ),
        ),
      ),
      home: const AuthWrapper(), // Check auth state on startup
    );
  }
}

/// Wrapper to check authentication state and navigate accordingly
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Tracks whether we've done the initial fast-path check
  bool _initialCheckDone = false;
  // Result of the fast-path check: null = not logged in, otherwise user data
  Map<String, dynamic>? _cachedUser;

  @override
  void initState() {
    super.initState();
    _doInitialCheck();
    // Hard failsafe: if after 5 seconds we are still not resolved, force navigation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_initialCheckDone) {
        setState(() => _initialCheckDone = true);
      }
    });
  }

  /// Fast-path: read persisted token + Firebase currentUser synchronously.
  /// This avoids the race between the stream emitting and our 5-second timeout.
  Future<void> _doInitialCheck() async {
    final authService = BackendAuthService();

    // 1. Try the already-resolved singleton currentUser first (instant)
    if (authService.currentUser != null) {
      if (mounted) {
        setState(() {
          _cachedUser = authService.currentUser;
          _initialCheckDone = true;
        });
      }
      return;
    }

    // 2. Check persisted user data from secure storage
    final tokenManager = TokenManager();
    await tokenManager.init();
    final isLoggedIn = await tokenManager.isLoggedIn();

    if (isLoggedIn) {
      final savedUser = await tokenManager.getUserData();
      // Only trust persisted data if it's a real user (not a guest)
      if (savedUser != null && savedUser['isGuest'] != true) {
        if (mounted) {
          setState(() {
            _cachedUser = savedUser;
            _initialCheckDone = true;
          });
        }
        return;
      }
    }

    // 3. No persisted session — mark check done, stream will determine final state
    if (mounted) {
      setState(() {
        _initialCheckDone = true;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final authService = BackendAuthService();
    final tokens = SeasonScope.of(context).tokens;

    // Show a brief splash while doing the initial fast-path check
    if (!_initialCheckDone) {
      return Scaffold(
        backgroundColor: tokens.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: tokens.gold),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: tokens.gold, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // If fast-path found a logged-in user, skip the stream and go directly
    if (_cachedUser != null) {
      return _buildDestination(_cachedUser!);
    }

    // If we timed out or the stream has a resolved currentUser, navigate immediately
    // without waiting for a stream event (avoids permanent "Checking session..." screen).
    return StreamBuilder<Map<String, dynamic>?>(
      stream: authService.authStateChanges,
      // Using currentUser as initialData means the builder runs immediately
      // with ConnectionState.active (not .waiting) when data is already available.
      initialData: authService.currentUser,
      builder: (context, snapshot) {
        // IMPORTANT: Do NOT show a loading screen for ConnectionState.waiting.
        // The broadcast stream may have already emitted before this widget built,
        // so it will never re-emit and we'd be stuck here forever.
        // Instead, treat "waiting with no initialData" as "not logged in".
        if (snapshot.hasData && snapshot.data != null) {
          return _buildDestination(snapshot.data!);
        }

        // Not logged in (or timed out) — show onboarding
        return const OnboardingFlowPage();
      },
    );
  }

  /// Builds the correct destination widget for an authenticated user.
  Widget _buildDestination(Map<String, dynamic> userData) {
    final isAdmin = userData['isAdmin'] == true;

    if (isAdmin) {
      return const AdminDashboard();
    }

    return FutureBuilder<bool>(
      future: _checkIfLocationSet(),
      builder: (context, locationSnapshot) {
        if (locationSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (locationSnapshot.data == true) {
          return const MainScreen();
        } else {
          return const LocationSetupPage();
        }
      },
    );
  }

  Future<bool> _checkIfLocationSet() async {
    final addressService = AddressService();
    await addressService.loadAddresses();
    return addressService.defaultAddress != null;
  }
}
