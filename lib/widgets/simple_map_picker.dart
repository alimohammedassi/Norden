import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

class SimpleMapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final Function(double latitude, double longitude, String address)
  onLocationSelected;

  const SimpleMapPicker({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<SimpleMapPicker> createState() => _SimpleMapPickerState();
}

class _SimpleMapPickerState extends State<SimpleMapPicker> {
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isGettingLocation = false;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      _selectedAddress = widget.initialAddress ?? '';
    } else {
      // Set default location first, then try to get current location
      _selectedLocation = const LatLng(30.0444, 31.2357);
      _selectedAddress = 'Cairo, Egypt (Default)';
      // Try to get current location on initialization
      _getCurrentLocationOnInit();
    }
  }

  void _getCurrentLocationOnInit() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      print('Getting current location on init...');

      // Use LocationService for better error handling
      final position = await _locationService.getCurrentPosition(
        showUserFeedback: true,
      );

      if (position != null) {
        print(
          'Current position on init: ${position.latitude}, ${position.longitude}',
        );

        final currentLocation = LatLng(position.latitude, position.longitude);

        // Try to get address from coordinates
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final address =
                '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
            setState(() {
              _selectedLocation = currentLocation;
              _selectedAddress = address.isNotEmpty
                  ? address
                  : 'Current Location';
              _isGettingLocation = false;
            });

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Current location found!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            setState(() {
              _selectedLocation = currentLocation;
              _selectedAddress = 'Current Location';
              _isGettingLocation = false;
            });
          }
        } catch (e) {
          print('Error getting address on init: $e');
          setState(() {
            _selectedLocation = currentLocation;
            _selectedAddress = 'Current Location';
            _isGettingLocation = false;
          });
        }
      } else {
        // Location service failed
        print('Failed to get current location on init');
        setState(() {
          _selectedLocation = const LatLng(30.0444, 31.2357);
          _selectedAddress = 'Cairo, Egypt (Default - Location unavailable)';
          _isGettingLocation = false;
        });

        // Show informative message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not access your location. Using default location. You can tap the location button to try again or select manually.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _getCurrentLocationOnInit: $e');
      setState(() {
        _selectedLocation = const LatLng(30.0444, 31.2357);
        _selectedAddress = 'Cairo, Egypt (Default Location)';
        _isGettingLocation = false;
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedAddress =
          'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
    });
    print('Map tapped at: ${location.latitude}, ${location.longitude}');
  }

  void _onCurrentLocationPressed() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      print('Getting current location...');

      // Use LocationService for better error handling
      final position = await _locationService.getCurrentPosition(
        showUserFeedback: true,
      );

      if (position != null) {
        print('Current position: ${position.latitude}, ${position.longitude}');

        final currentLocation = LatLng(position.latitude, position.longitude);

        // Try to get address from coordinates
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final address =
                '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
            setState(() {
              _selectedLocation = currentLocation;
              _selectedAddress = address.isNotEmpty
                  ? address
                  : 'Current Location';
              _isGettingLocation = false;
            });

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Current location found!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            setState(() {
              _selectedLocation = currentLocation;
              _selectedAddress = 'Current Location';
              _isGettingLocation = false;
            });
          }
        } catch (e) {
          print('Error getting address: $e');
          setState(() {
            _selectedLocation = currentLocation;
            _selectedAddress = 'Current Location';
            _isGettingLocation = false;
          });
        }
      } else {
        // Location service failed
        print('Failed to get current location');
        setState(() {
          _selectedLocation = const LatLng(30.0444, 31.2357);
          _selectedAddress = 'Cairo, Egypt (Default - Location unavailable)';
          _isGettingLocation = false;
        });

        // Show error message with helpful instructions
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Could not access your location. Please check location permissions and try again, or select a location manually on the map.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _onCurrentLocationPressed: $e');
      setState(() {
        _selectedLocation = const LatLng(30.0444, 31.2357);
        _selectedAddress = 'Cairo, Egypt (Default Location)';
        _isGettingLocation = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An error occurred while getting your location. Please try again or select manually.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onConfirmPressed() {
    print('=== CONFIRM LOCATION PRESSED ===');
    print('Selected location: $_selectedLocation');
    print('Selected address: $_selectedAddress');

    if (_selectedLocation != null) {
      print('Calling onLocationSelected callback...');
      print('Latitude: ${_selectedLocation!.latitude}');
      print('Longitude: ${_selectedLocation!.longitude}');
      print('Address: $_selectedAddress');

      widget.onLocationSelected(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        _selectedAddress,
      );
      print('Callback completed, navigating back...');
      Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location selected successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('No location selected!');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location first'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    // Map controller not needed for this simple implementation
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? const LatLng(30.0444, 31.2357),
                    zoom: 15.0,
                  ),
                  onTap: _onMapTap,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: _selectedLocation!,
                            infoWindow: InfoWindow(
                              title: 'Selected Location',
                              snippet: _selectedAddress,
                            ),
                          ),
                        }
                      : {},
                  mapType: MapType.normal,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                ),
                // Current location button
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFFD4AF37),
                    onPressed: _isGettingLocation
                        ? null
                        : _onCurrentLocationPressed,
                    child: _isGettingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : const Icon(Icons.my_location, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          // Address display and confirm button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Address:',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onConfirmPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CONFIRM LOCATION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
