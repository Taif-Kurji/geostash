import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/utils/group_code.dart';

void main() {
  test('generateGroupCode returns correct length', () {
    final code = generateGroupCode(random: Random(42), length: 8);
    expect(code.length, 8);
  });

  test('generateGroupCode uses allowed characters', () {
    final code = generateGroupCode(random: Random(1), length: 64);
    const allowed = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    for (final ch in code.split('')) {
      expect(allowed.contains(ch), isTrue);
    }
  });
}

