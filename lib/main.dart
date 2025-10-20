import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';
import 'screens/NordenIntroPage.dart';
import 'screens/admin/admin_dashboard.dart';
import 'services/backend_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If Firebase isn't configured yet, continue without crashing so the app can start
    debugPrint('Firebase init error: $e');
  }

  // Initialize backend auth service with timeout
  final authService = BackendAuthService();
  await authService.initWithTimeout();

  runApp(const NordenApp());
}

class NordenApp extends StatelessWidget {
  const NordenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        primaryColor: const Color(0xFF1B263B),
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
          bodyLarge: GoogleFonts.inter(),
          bodyMedium: GoogleFonts.inter(),
          displayLarge: GoogleFonts.playfairDisplay(),
          displayMedium: GoogleFonts.playfairDisplay(),
          displaySmall: GoogleFonts.playfairDisplay(),
          headlineLarge: GoogleFonts.playfairDisplay(),
          headlineMedium: GoogleFonts.playfairDisplay(),
          headlineSmall: GoogleFonts.playfairDisplay(),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFB8860B),
          surface: Color(0xFF1B263B),
          background: Color(0xFF0A0E1A),
          onPrimary: Color(0xFF0A0E1A),
          onSecondary: Color(0xFF0A0E1A),
          onSurface: Color(0xFFB8D4E8),
          onBackground: Color(0xFFB8D4E8),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD4AF37),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF0A0E1A),
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
          color: const Color(0xFF1B263B).withOpacity(0.6),
          elevation: 8,
          shadowColor: const Color(0xFFD4AF37).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              width: 1,
            ),
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
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    // Set a timeout to show intro page if auth check takes too long
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = BackendAuthService();

    // If timeout occurred, show intro page
    if (_hasTimedOut) {
      return const NordenIntroPage();
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state (with timeout)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // If user is logged in, go to appropriate page
        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!;
          final isAdmin = userData['isAdmin'] == true;

          if (isAdmin) {
            return const AdminDashboard();
          } else {
            return const NordenHomePage();
          }
        }

        // If user is not logged in, show intro page
        return const NordenIntroPage();
      },
    );
  }
}
