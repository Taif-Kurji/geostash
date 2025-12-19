import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/utils/geo.dart';

void main() {
  test('distanceBetweenPointsMeters is zero for identical points', () {
    final d = distanceBetweenPointsMeters(lat1: 1, lon1: 2, lat2: 1, lon2: 2);
    expect(d, 0);
  });

  test('distanceBetweenPointsMeters is symmetric', () {
    final d1 = distanceBetweenPointsMeters(lat1: 0, lon1: 0, lat2: 0, lon2: 1);
    final d2 = distanceBetweenPointsMeters(lat1: 0, lon1: 1, lat2: 0, lon2: 0);
    expect((d1 - d2).abs(), lessThan(0.0001));
  });

  test('distanceBetweenPointsMeters approx distance at equator', () {
    final d = distanceBetweenPointsMeters(lat1: 0, lon1: 0, lat2: 0, lon2: 1);
    expect(d, inInclusiveRange(110000, 112500));
  });
}
