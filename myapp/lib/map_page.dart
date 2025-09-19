import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _start = CameraPosition(
    target: LatLng(59.3293, 18.0686),
    zoom: 12,
  );

  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoStash Map')),
      body: GoogleMap(
        initialCameraPosition: _start,
        markers: _markers,
        onTap: (latLng) {
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId('${latLng.latitude},${latLng.longitude}'),
                position: latLng,
                infoWindow: const InfoWindow(title: 'New cache'),
              ),
            );
          });
        },
      ),
    );
  }
}
