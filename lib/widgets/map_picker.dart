import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class MapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final Function(double latitude, double longitude, String address)
  onLocationSelected;

  const MapPicker({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        _selectedLocation = LatLng(
          widget.initialLatitude!,
          widget.initialLongitude!,
        );
        _selectedAddress = widget.initialAddress ?? '';
      } else {
        // Try to get current location, but don't fail if it doesn't work
        try {
          final position = await _locationService.getCurrentPosition();
          if (position != null) {
            _selectedLocation = LatLng(position.latitude, position.longitude);
            _selectedAddress =
                await _locationService.getAddressFromCoordinates(
                  position.latitude,
                  position.longitude,
                ) ??
                'Selected Location';
          } else {
            // Default to Cairo, Egypt
            _selectedLocation = const LatLng(30.0444, 31.2357);
            _selectedAddress = 'Cairo, Egypt';
          }
        } catch (e) {
          print('Location service error: $e');
          // Default to Cairo, Egypt if location services fail
          _selectedLocation = const LatLng(30.0444, 31.2357);
          _selectedAddress = 'Cairo, Egypt';
        }
      }
    } catch (e) {
      print('Initialization error: $e');
      // Fallback to default location
      _selectedLocation = const LatLng(30.0444, 31.2357);
      _selectedAddress = 'Cairo, Egypt';
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateAddressFromLocation(location);
  }

  Future<void> _updateAddressFromLocation(LatLng location) async {
    try {
      final address = await _locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      setState(() {
        _selectedAddress = address ?? 'Selected Location';
      });
    } catch (e) {
      print('Address update error: $e');
      setState(() {
        _selectedAddress = 'Selected Location';
      });
    }
  }

  void _onCurrentLocationPressed() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final location = LatLng(position.latitude, position.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLng(location));
        _onMapTap(location);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get current location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Current location error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onConfirmPressed() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        _selectedAddress,
      );
      Navigator.of(context).pop();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              ),
            )
          : Column(
              children: [
                // Map
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation!,
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
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      ),
                      // Current location button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: const Color(0xFFD4AF37),
                          onPressed: _onCurrentLocationPressed,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.black,
                          ),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
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
