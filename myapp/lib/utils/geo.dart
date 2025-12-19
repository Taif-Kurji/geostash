import 'dart:math';

double distanceBetweenPointsMeters({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  //  Jordens radie i meter 
  const r = 6371000.0;

  // Omvandla till radianer.
  final lat1Rad = lat1 * pi / 180;
  final lat2Rad = lat2 * pi / 180;
  final dLat = lat2Rad - lat1Rad;
  final dLon = (lon2 - lon1) * pi / 180;

  final sinLat = sin(dLat / 2);
  final sinLon = sin(dLon / 2);

  // Haversine-formeln enligt yt tutorial.
  final a = sinLat * sinLat + cos(lat1Rad) * cos(lat2Rad) * sinLon * sinLon;
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}
