import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DebugMapsPicker extends StatefulWidget {
  const DebugMapsPicker({Key? key}) : super(key: key);

  @override
  State<DebugMapsPicker> createState() => _DebugMapsPickerState();
}

class _DebugMapsPickerState extends State<DebugMapsPicker> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(40.7128, -74.0060); // NYC
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _status = 'Checking permissions...');

    try {
      final permission = await Geolocator.checkPermission();
      setState(() {
        _status = 'Permission status: $permission';
      });
    } catch (e) {
      setState(() {
        _status = 'Permission error: $e';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _status = 'Map created successfully!';
    });
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _status =
          'Selected: ${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFD4AF37),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'DEBUG MAPS',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Status
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2A2A2A),
              child: Text(
                _status,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            // Map
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    onTap: _onMapTap,
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedLocation,
                        infoWindow: const InfoWindow(
                          title: 'Selected Location',
                        ),
                      ),
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),
            ),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tap anywhere on the map to select a location.\nIf you see this map, Google Maps is working!',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
