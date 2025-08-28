import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/core.dart';

class LocationPage extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  const LocationPage({
    super.key,
    this.latitude,
    this.longitude,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? mapController;
  bool mapError = false;
  String errorDetails = '';

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (kDebugMode) {
      debugPrint('✅ Google Map created successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug coordinates
    if (kDebugMode) {
      debugPrint('🗺️ LocationPage coordinates: lat=${widget.latitude}, lng=${widget.longitude}');
    }

    // Check for valid coordinates
    bool hasValidCoordinates = widget.latitude != null &&
                              widget.longitude != null &&
                              widget.latitude != 0 &&
                              widget.longitude != 0;

    LatLng center = LatLng(
      widget.latitude ?? -6.2088, // Default to Jakarta if null
      widget.longitude ?? 106.8456
    );

    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId("user_location"),
        position: center,
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: hasValidCoordinates
            ? 'Lat: ${widget.latitude?.toStringAsFixed(6)}, Lng: ${widget.longitude?.toStringAsFixed(6)}'
            : 'Default location (GPS not available)',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.latitude == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Getting your location...'),
                      ],
                    ),
                  )
                : mapError
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Google Maps Error',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                errorDetails.isEmpty
                                  ? 'Google Maps API key is missing or invalid.\n\nTo fix this:\n1. Get free API key from Google Cloud Console\n2. Replace "YOUR_ANDROID_API_KEY_HERE" in AndroidManifest.xml\n3. Hot restart the app'
                                  : errorDetails,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        mapError = false;
                                        errorDetails = '';
                                      });
                                    },
                                    child: const Text('Retry'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Show coordinates in a dialog as fallback
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Your Location'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Latitude: ${widget.latitude?.toStringAsFixed(6) ?? 'Unknown'}'),
                                              Text('Longitude: ${widget.longitude?.toStringAsFixed(6) ?? 'Unknown'}'),
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Location detected successfully!\nGoogle Maps needs API key to display map.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.info),
                                    label: const Text('Show Info'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          try {
                            _onMapCreated(controller);
                          } catch (e) {
                            if (kDebugMode) {
                              debugPrint('❌ Map creation error: $e');
                            }
                            setState(() {
                              mapError = true;
                              errorDetails = e.toString();
                            });
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: center,
                          zoom: hasValidCoordinates ? 18.0 : 10.0,
                        ),
                        markers: markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        compassEnabled: true,
                        rotateGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                      ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 50.0,
            ),
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Assets.icons.back.svg(),
            ),
          ),
        ],
      ),
    );
  }
}