import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CacheModel extends ChangeNotifier {
  CacheModel(FirebaseFirestore firestore, this._ownerId)
      : _collection = firestore.collection('caches') {
    final query = _collection.where('ownerId', isEqualTo: _ownerId);
    _subscription = query.snapshots().listen(
      _onSnapshot,
      onError: _onError,
    );
  }

  final CollectionReference<Map<String, dynamic>> _collection;
  final String _ownerId;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _subscription;

  final List<GeoCache> _caches = [];
  bool _hasSynced = false;
  String? _errorMessage;

  List<GeoCache> get caches => List.unmodifiable(_caches);
  bool get isLoading => !_hasSynced && _errorMessage == null;
  String? get errorMessage => _errorMessage;

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    _caches
      ..clear()
      ..addAll(snapshot.docs.map(GeoCache.fromDoc));
    _hasSynced = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error, StackTrace stackTrace) {
    _errorMessage = error.toString();
    notifyListeners();
  }

  Future<void> addCache({
    required String title,
    required double latitude,
    required double longitude,
  }) async {
    await _collection.add({
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': _ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class GeoCache {
  GeoCache({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  factory GeoCache.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data['createdAt'];
    return GeoCache(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled cache',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
