import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NordenForgotPasswordPage extends StatefulWidget {
  const NordenForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<NordenForgotPasswordPage> createState() =>
      _NordenForgotPasswordPageState();
}

class _NordenForgotPasswordPageState extends State<NordenForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
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
              Color(0xFF000000),
              Color(0xFF0A0E1A),
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Back button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFFB8D4E8),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Header
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFF5E9FD8)],
                            ).createShader(bounds),
                            child: Text(
                              'Forgot\nPassword?',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 42,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _emailSent
                                ? 'Check your email for reset instructions'
                                : 'Enter your email to reset password',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFF8BA8C5),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Content
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _emailSent
                            ? _buildEmailSentContent()
                            : _buildResetForm(),
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

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your registered email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          // Reset button
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
                  if (_formKey.currentState!.validate()) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _emailSent = true;
                    });
                    // Here you would typically send the reset email
                  }
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
                  'SEND RESET LINK',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Back to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password? ",
                style: GoogleFonts.inter(
                  color: Color(0xFF8BA8C5),
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    color: Color(0xFF5E9FD8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentContent() {
    return Column(
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(24),
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
            Icons.mark_email_read_outlined,
            size: 60,
            color: Color(0xFF5E9FD8),
          ),
        ),
        const SizedBox(height: 32),
        // Success message
        Text(
          'Reset Link Sent!',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Color(0xFF8BA8C5),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        // Resend button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color(0xFF5E9FD8).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Resend email logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reset link sent again!'),
                    backgroundColor: Color(0xFF5E9FD8),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xFF5E9FD8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'RESEND LINK',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Back to login
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Back to Sign In',
            style: GoogleFonts.inter(
              color: Color(0xFF8BA8C5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFFB8D4E8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF000000).withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: Color(0xFF8BA8C5).withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: Color(0xFF5E9FD8), size: 22),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Color(0xFF1B263B).withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Color(0xFF2E5C8A).withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Color(0xFF2E5C8A).withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFF5E9FD8), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFFE94560)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFFE94560), width: 1.5),
              ),
              errorStyle: GoogleFonts.inter(
                color: Color(0xFFE94560),
                fontSize: 12,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
