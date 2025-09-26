import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'data/cache_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final cacheModel = context.watch<CacheModel>();
    final caches = cacheModel.caches;
    final markers = caches
        .map(
          (cache) => Marker(
            markerId: MarkerId(cache.id),
            position: LatLng(cache.latitude, cache.longitude),
            infoWindow: InfoWindow(title: cache.title),
          ),
        )
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('GeoStash Map')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _start,
              markers: markers,
              onTap: (latLng) async {
                try {
                  await cacheModel.addCache(
                    title: 'Ny cache',
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kunde inte spara cache: $error')),
                  );
                }
              },
            ),
          ),
          SizedBox(
            height: 160,
            child: Builder(
              builder: (_) {
                if (cacheModel.errorMessage != null) {
                  return Center(
                    child: Text('Kunde inte ladda cache: ${cacheModel.errorMessage}'),
                  );
                }
                if (cacheModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (caches.isEmpty) {
                  return const Center(
                    child: Text('Inga cacher ännu – tryck på kartan för att skapa en.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (_, index) {
                    final cache = caches[index];
                    return ListTile(
                      title: Text(cache.title),
                      subtitle: Text(
                        '${cache.latitude.toStringAsFixed(5)}, '
                        '${cache.longitude.toStringAsFixed(5)}',
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: caches.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
