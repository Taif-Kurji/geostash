import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FindModel extends ChangeNotifier {
  FindModel(FirebaseFirestore firestore, this._userId, this._groupId)
      : _collection = firestore.collection('finds') {
    // listen to found for current user and group
    final query = _collection
        .where('userId', isEqualTo: _userId)
        .where('groupId', isEqualTo: _groupId);
    _subscription = query.snapshots().listen(
      _onSnapshot,
      onError: _onError,
    );
  }

  final CollectionReference<Map<String, dynamic>> _collection;
  final String _userId;
  final String _groupId;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _subscription;

  final Set<String> _foundCacheIds = {};
  bool _hasSynced = false;
  String? _errorMessage;

  bool get isLoading => !_hasSynced && _errorMessage == null;
  String? get errorMessage => _errorMessage;
  Set<String> get foundCacheIds => Set.unmodifiable(_foundCacheIds);

  bool isFound(String cacheId) => _foundCacheIds.contains(cacheId);

  Future<void> markFound(String cacheId) {
    // marker som found
    final docId = '${cacheId}_$_userId';
    return _collection.doc(docId).set({
      'cacheId': cacheId,
      'userId': _userId,
      'groupId': _groupId,
      'foundAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unmarkFound(String cacheId) {
    // unfind
    final docId = '${cacheId}_$_userId';
    return _collection.doc(docId).delete();
  }

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    _foundCacheIds
      ..clear()
      ..addAll(
        snapshot.docs.map((d) => (d.data()['cacheId'] as String?) ?? ''),
      );
    _foundCacheIds.remove('');
    _hasSynced = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error, StackTrace stackTrace) {
    _errorMessage = error.toString();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
