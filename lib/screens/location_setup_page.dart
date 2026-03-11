import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/google_maps_picker.dart';
import '../services/location_service.dart';
import '../services/address_service.dart';
import '../services/backend_auth_service.dart';
import 'home_page.dart';
import '../providers/season_provider.dart';
import '../config/app_theme.dart';

class LocationSetupPage extends StatefulWidget {
  const LocationSetupPage({Key? key}) : super(key: key);

  @override
  State<LocationSetupPage> createState() => _LocationSetupPageState();
}

class _LocationSetupPageState extends State<LocationSetupPage> {
  SeasonTokens get t => SeasonScope.of(context).tokens;
  final LocationService _locationService = LocationService();
  final AddressService _addressService = AddressService();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedCountry = 'Unknown';

  final Map<String, String> _countryCodeMap = {
    '+1': 'USA',
    '+44': 'UK',
    '+971': 'UAE',
    '+966': 'Saudi Arabia',
    '+20': 'Egypt',
    '+965': 'Kuwait',
    '+974': 'Qatar',
    '+973': 'Bahrain',
    '+968': 'Oman',
    '+Jordan': 'Jordan',
    '+962': 'Jordan',
    '+Libya': 'Libya',
    '+218': 'Libya',
    '+212': 'Morocco',
    '+213': 'Algeria',
    '+216': 'Tunisia',
    '+961': 'Lebanon',
    '+963': 'Syria',
    '+964': 'Iraq',
  };

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    if (value.isEmpty) return;
    String prefix = '';
    if (value.startsWith('+')) {
      if (value.length >= 4) {
        prefix = value.substring(0, 4);
        if (!_countryCodeMap.containsKey(prefix)) {
          prefix = value.substring(0, 3);
          if (!_countryCodeMap.containsKey(prefix)) {
            prefix = value.substring(0, 2);
          }
        }
      } else if (value.length >= 3) {
        prefix = value.substring(0, 3);
        if (!_countryCodeMap.containsKey(prefix)) {
          prefix = value.substring(0, 2);
        }
      } else if (value.length >= 2) {
        prefix = value.substring(0, 2);
      }
    }

    if (_countryCodeMap.containsKey(prefix)) {
      setState(() {
        _selectedCountry = _countryCodeMap[prefix]!;
      });
    }
  }

  void _completeSetup() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NordenHomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _processMapResult(Map<String, dynamic> result) async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    String city = 'Unknown';
    String country = 'Unknown';
    try {
      List<Placemark> marks = await placemarkFromCoordinates(
        result['latitude'],
        result['longitude'],
      );
      if (marks.isNotEmpty) {
        city = marks[0].locality ?? marks[0].administrativeArea ?? 'Unknown';
        country = marks[0].country ?? 'Unknown';
      }
    } catch (_) {}

    // Save to local AddressService
    final authService = BackendAuthService();
    final userName = authService.currentUser?['displayName'] ?? 'User';

    await _addressService.addAddress(
      label: 'Home',
      name: userName,
      phone: _phoneController.text,
      street: 'Selected via Map',
      city: city,
      country: country,
      isDefault: true,
    );

    // Send to backend account endpoint
    await _locationService.syncLocationToBackend(
      latitude: result['latitude'],
      longitude: result['longitude'],
      city: city,
      country: country,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _completeSetup();
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final position = await _locationService.getCurrentPosition();

      if (position != null && mounted) {
        setState(() => _isLoading = false); // Done loading pos

        // Open map focused on their location so they can verify and submit
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get location. Please try manually.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _enterManually() async {
    HapticFeedback.lightImpact();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const GoogleMapsPicker(initialLabel: 'Home'),
      ),
    );

    if (result != null && mounted) {
      // User selected a location on the map, save to account
      await _processMapResult(result);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Header Map Graphic
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          t.gold.withOpacity(0.2),
                          t.bg,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.my_location_rounded,
                        size: 80,
                        color: t.gold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Titles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      Text(
                        'Set Your Location',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We use your location to provide personalized '
                        'delivery estimates and store recommendations.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Phone number field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: GoogleFonts.inter(
                          color: t.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: t.gold.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          onChanged: _onPhoneChanged,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'e.g. +971 50 123 4567',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: t.gold,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      if (_selectedCountry != 'Unknown')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.public_rounded,
                                color: t.gold,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Detected Region: $_selectedCountry',
                                style: GoogleFonts.inter(
                                  color: t.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    children: [
                      // Use Current Location
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [t.gold, const Color(0xFFB8860B)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: t.gold.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: _isLoading ? null : _useCurrentLocation,
                          style: TextButton.styleFrom(
                            foregroundColor: t.bg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: t.bg,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.gps_fixed_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Use Current Location',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Enter Manually
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: _isLoading ? null : _enterManually,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Enter Location Manually',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Skip
                      TextButton(
                        onPressed: _isLoading ? null : _completeSetup,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.5),
                        ),
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
