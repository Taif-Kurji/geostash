import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'data/auth_model.dart';
import 'data/cache_model.dart';
import 'data/find_model.dart';
import 'l10n/app_localizations.dart';
import 'utils/geo.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //    Startvy om position saknas.
  static const _start = CameraPosition(
    target: LatLng(59.3293, 18.0686),
    zoom: 12,
  );

  //    Kartkontroller och platsstatus.
  GoogleMapController? _mapController;
  LatLng? _pendingCenter;
  Position? _position;
  bool _locationBusy = false;
  String? _locationError;
  bool _hideFound = true; //    Styr om hittade cacher ska döljas.

  @override
  void initState() {
    super.initState();
    //    Försök hämta position direkt.
    _loadLocation();
  }

  @override
  void dispose() {
    //    Stäng kartkontrollern när sidan försvinner.
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  Future<_NewCache?> _promptNewCache() async {
    //    Dialog för ny cache (titel/beskrivning).
    return showDialog<_NewCache>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => const _NewCacheDialog(),
    );
  }

  Future<void> _showCacheActions(GeoCache cache, {double? distanceMeters}) async {
    final l = AppLocalizations.of(context)!;
    final auth = context.read<AuthModel>();
    final cacheModel = context.read<CacheModel>();
    final findModel = context.read<FindModel>();

    //  Tillåt ta bort om ägare, kolla hittad-status.
    final canDelete = auth.user?.uid != null && cache.ownerId == auth.user!.uid;
    final isFound = findModel.isFound(cache.id);

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: false,
      showDragHandle: false,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(cache.title, style: Theme.of(sheetContext).textTheme.titleMedium),
              if (cache.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(cache.description),
              ],
              const SizedBox(height: 6),
              Text(
                distanceMeters == null
                    ? '${cache.latitude.toStringAsFixed(5)}, ${cache.longitude.toStringAsFixed(5)}'
                    : '${distanceMeters.toStringAsFixed(0)} m',
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  try {
                    if (isFound) {
                      await findModel.unmarkFound(cache.id);
                    } else {
                      await findModel.markFound(cache.id);
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text(isFound ? l.unmarkFound : l.markFound),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _centerMap(LatLng(cache.latitude, cache.longitude), zoom: 16);
                },
                child: Text(l.centerOnMap),
              ),
              if (canDelete) ...[
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () async {
                    final sheetNavigator = Navigator.of(sheetContext);
                    final ok = await showDialog<bool>(
                      context: sheetContext,
                      useRootNavigator: false,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l.deleteCache),
                        content: Text(l.deleteCacheConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: Text(l.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: Text(l.delete),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    if (!sheetContext.mounted || !mounted) return;

                    sheetNavigator.pop();
                    try {
                      await cacheModel.deleteCache(cache.id);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: Text(l.deleteCache),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _createCacheAt(LatLng latLng) async {
    final l = AppLocalizations.of(context)!;
    final draft = await _promptNewCache();
    if (draft == null) return;
    if (!mounted) return;

    final cacheModel = context.read<CacheModel>();
    try {
      //    Spara ny cache i Firestore via modellen.
      await cacheModel.addCache(
        title: draft.title,
        description: draft.description,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.couldNotSaveCache}: $error')),
      );
    }
  }

  void _centerMap(LatLng target, {double zoom = 14}) {
    final controller = _mapController;
    if (controller == null) {
      //    sthlmtills kartan är redo.
      _pendingCenter = target;
      return;
    }
    //     förflyttning till vald punkt.
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  Future<void> _loadLocation() async {
    setState(() {
      _locationBusy = true;
      _locationError = null;
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw StateError('Platstjänster är avstängda.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw StateError('Ingen platsbehörighet.');
      }
      //    Hämta nuvarande position och centrera kartan.
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _position = pos);
        _centerMap(LatLng(pos.latitude, pos.longitude));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _locationError = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _locationBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cacheModel = context.watch<CacheModel>();
    final findModel = context.watch<FindModel>();
    final allCaches = cacheModel.caches;
    final List<GeoCache> caches = _hideFound
        ? allCaches.where((cache) => !findModel.isFound(cache.id)).toList()
        : allCaches;
    //     synliga cacher.
    final markers = caches
        .map(
          (cache) => Marker(
            markerId: MarkerId(cache.id),
            position: LatLng(cache.latitude, cache.longitude),
            infoWindow: InfoWindow(
              title: cache.title,
              snippet: cache.description.isEmpty ? null : cache.description,
            ),
            onTap: () {
              //    Beräkna avstånd och visa val för vald cache.
              final distance = _position == null
                  ? null
                  : distanceBetweenPointsMeters(
                      lat1: _position!.latitude,
                      lon1: _position!.longitude,
                      lat2: cache.latitude,
                      lon2: cache.longitude,
                    );
              _showCacheActions(cache, distanceMeters: distance);
            },
          ),
        )
        .toSet();
    final sorted = _position == null
        ? caches
        : (caches.toList()
          ..sort(
            (a, b) {
              //    Sortera på avstånd när position finns.
              final da = distanceBetweenPointsMeters(
                lat1: _position!.latitude,
                lon1: _position!.longitude,
                lat2: a.latitude,
                lon2: a.longitude,
              );
              final db = distanceBetweenPointsMeters(
                lat1: _position!.latitude,
                lon1: _position!.longitude,
                lat2: b.latitude,
                lon2: b.longitude,
              );
              return da.compareTo(db);
            },
          ));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.mapTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _hideFound = !_hideFound),
                    child: Text(_hideFound ? l.showFoundCaches : l.hideFoundCaches),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _locationBusy ? null : _loadLocation,
                    child: Text(l.updatePosition),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _position == null
                  ? _start
                  : CameraPosition(
                      target: LatLng(_position!.latitude, _position!.longitude),
                      zoom: 14,
                    ),
              markers: markers,
              myLocationEnabled: _position != null, //    Visa blå punkt om position finns.
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                final pending = _pendingCenter;
                if (pending != null) {
                  //    Om väntat på centrum, använd det nu.
                  _pendingCenter = null;
                  _centerMap(pending);
                } else if (_position != null) {
                  //    Annars centrera på känd position.
                  _centerMap(LatLng(_position!.latitude, _position!.longitude));
                }
              },
              onTap: _createCacheAt,
            ),
          ),
          SizedBox(
            height: 160,
            child: Builder(
              builder: (context) {
                if (_locationError != null) {
                  //    Visa fel om plats inte kunde hämtas.
                  return Center(child: Text(_locationError!));
                }
                if (cacheModel.errorMessage != null) {
                  return Center(
                    child: Text('${l.couldNotLoadCaches}: ${cacheModel.errorMessage}'),
                  );
                }
                if (cacheModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (caches.isEmpty) {
                  if (allCaches.isNotEmpty && _hideFound) {
                    //    Det finns cacher men alla är hittade och dolda.
                    return Center(child: Text(l.noUnfoundCaches));
                  }
                  //    Helt tom lista.
                  return Center(
                    child: Text(l.noCachesYet),
                  );
                }
                //    Lista cachar; varje rad kan markeras hittad eller öppnas.
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final cache = sorted[index];
                    final isFound = findModel.isFound(cache.id);
                    final distance = _position == null
                        ? null
                        : distanceBetweenPointsMeters(
                            lat1: _position!.latitude,
                            lon1: _position!.longitude,
                            lat2: cache.latitude,
                            lon2: cache.longitude,
                          );
                    final parts = <String>[];
                    if (distance != null) parts.add('${distance.toStringAsFixed(0)} m');
                    if (cache.description.isNotEmpty) parts.add(cache.description);
                    final subtitle = parts.isEmpty
                        ? '${cache.latitude.toStringAsFixed(5)}, ${cache.longitude.toStringAsFixed(5)}'
                        : parts.join(' • ');
                    return ListTile(
                      title: Text(cache.title),
                      subtitle: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showCacheActions(cache, distanceMeters: distance),
                      trailing: TextButton(
                        onPressed: () async {
                          try {
                            if (isFound) {
                              await findModel.unmarkFound(cache.id);
                            } else {
                              await findModel.markFound(cache.id);
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: Text(isFound ? l.unmarkFound : l.markFound),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemCount: sorted.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NewCache {
  const _NewCache({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class _NewCacheDialog extends StatefulWidget {
  const _NewCacheDialog();

  @override
  State<_NewCacheDialog> createState() => _NewCacheDialogState();
}

class _NewCacheDialogState extends State<_NewCacheDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool get _canSubmit => _titleController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.createCache),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l.cacheTitle),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: l.cacheDescription),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        ElevatedButton(
          onPressed: _canSubmit
              ? () {
                  Navigator.of(context).pop(
                    _NewCache(
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                    ),
                  );
                }
              : null,
          child: Text(l.create),
        ),
      ],
    );
  }
}
