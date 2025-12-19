import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CacheModel extends ChangeNotifier {
  CacheModel(FirebaseFirestore firestore, this._ownerId, this._groupId)
      : _firestore = firestore,
        _collection = firestore.collection('caches'),
        _finds = firestore.collection('finds') {
    // listen to caches in group.
    final query = _collection.where('groupId', isEqualTo: _groupId);
    _subscription = query.snapshots().listen(
      _onSnapshot,
      onError: _onError,
    );
  }

  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _collection;
  final CollectionReference<Map<String, dynamic>> _finds;
  final String _ownerId;
  final String _groupId;
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
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    // new cache.
    await _collection.add({
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'groupId': _groupId,
      'ownerId': _ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCache(String cacheId) async {
    // removes cache.
    await _collection.doc(cacheId).delete();

    final query = await _finds
        .where('cacheId', isEqualTo: cacheId)
        .where('groupId', isEqualTo: _groupId)
        .get();
    if (query.docs.isEmpty) return;

    WriteBatch batch = _firestore.batch();
    var count = 0;
    for (final doc in query.docs) {
      batch.delete(doc.reference);
      count += 1;
      if (count >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
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
    required this.groupId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  final String id;
  final String groupId;
  final String ownerId;
  final String title;
  final String description;
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
      groupId: data['groupId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled cache',
      description: data['description'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
