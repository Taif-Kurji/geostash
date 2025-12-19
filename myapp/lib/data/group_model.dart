import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../utils/group_code.dart';

class GroupModel extends ChangeNotifier {
  GroupModel(FirebaseFirestore firestore, this._userId)
      : _groups = firestore.collection('groups'),
        _memberships = firestore.collection('memberships') {
    // listen for memberships
    final query = _memberships.where('userId', isEqualTo: _userId);
    _subscription = query.snapshots().listen(
      _onSnapshot,
      onError: _onError,
    );
  }

  final String _userId;
  final CollectionReference<Map<String, dynamic>> _groups;
  final CollectionReference<Map<String, dynamic>> _memberships;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _subscription;

  final List<GroupInfo> _items = [];
  bool _hasSynced = false;
  String? _errorMessage;
  String? _selectedGroupId;

  List<GroupInfo> get groups => List.unmodifiable(_items);
  bool get isLoading => !_hasSynced && _errorMessage == null;
  String? get errorMessage => _errorMessage;
  String? get selectedGroupId => _selectedGroupId;
  GroupInfo? get selectedGroup =>
      _selectedGroupId == null ? null : _items.where((g) => g.id == _selectedGroupId).firstOrNull;

  void selectGroup(String groupId) {
    if (_selectedGroupId == groupId) return;
    _selectedGroupId = groupId;
    notifyListeners();
  }

  Future<void> createGroup(String name) async {
    // creates group and the founder becomes a menber
    final code = generateGroupCode();
    final groupRef = await _groups.add({
      'name': name,
      'code': code,
      'ownerId': _userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _memberships.doc('${groupRef.id}_$_userId').set({
      'groupId': groupRef.id,
      'groupName': name,
      'groupCode': code,
      'userId': _userId,
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> joinGroup(String code) async {
    // join group via code
    final normalized = code.trim().toUpperCase();
    final snapshot = await _groups.where('code', isEqualTo: normalized).limit(1).get();
    if (snapshot.docs.isEmpty) {
      throw StateError('Ingen grupp hittades med den koden.');
    }
    final group = snapshot.docs.first;
    final data = group.data();
    final groupId = group.id;
    final groupName = (data['name'] as String?) ?? 'Grupp';
    final groupCode = (data['code'] as String?) ?? normalized;

    await _memberships.doc('${groupId}_$_userId').set({
      'groupId': groupId,
      'groupName': groupName,
      'groupCode': groupCode,
      'userId': _userId,
      'role': 'member',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    // group list
    _items
      ..clear()
      ..addAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          return GroupInfo(
            id: data['groupId'] as String? ?? '',
            name: data['groupName'] as String? ?? 'Grupp',
            code: data['groupCode'] as String? ?? '',
            role: data['role'] as String? ?? 'member',
          );
        }).where((g) => g.id.isNotEmpty),
      );

    if (_selectedGroupId == null || _items.every((g) => g.id != _selectedGroupId)) {
      //  Om vald grupp saknas, välj första eller null.
      _selectedGroupId = _items.isEmpty ? null : _items.first.id;
    }

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

class GroupInfo {
  GroupInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.role,
  });

  final String id;
  final String name;
  final String code;
  final String role;
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
