/// Model class for a favorite location.
class FavoriteLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// Predefined favorite locations (at least 3).
const List<FavoriteLocation> favoriteLocations = [
  FavoriteLocation(
    id: 1,
    name: 'Khulna University',
    latitude: 22.8026,
    longitude: 89.3709,
  ),
  FavoriteLocation(
    id: 2,
    name: 'Khulna Railway Station',
    latitude: 22.8153,
    longitude: 89.5635,
  ),
  FavoriteLocation(
    id: 3,
    name: 'Shibbari More',
    latitude: 22.8190,
    longitude: 89.5530,
  ),
  FavoriteLocation(
    id: 4,
    name: 'Daulatpur Bus Stand',
    latitude: 22.8710,
    longitude: 89.5300,
  ),
];
