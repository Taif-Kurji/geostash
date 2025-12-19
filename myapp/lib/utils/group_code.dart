import 'dart:math';

String generateGroupCode({Random? random, int length = 6}) {
  final r = random ?? Random.secure();
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  // Slumpa en kod.
  return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
}
