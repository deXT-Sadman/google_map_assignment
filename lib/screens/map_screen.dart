import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/favorite_location.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final Completer<GoogleMapController> _controller = Completer();

  bool _locationGranted = false;
  bool _loadingLocation = false;
  Marker? _userMarker;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(22.8456, 89.5403), // Khulna city area
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await _locationService.hasPermission();
    if (mounted) setState(() => _locationGranted = granted);
  }

  Set<Marker> get _markers {
    final markers = favoriteLocations.map((loc) {
      return Marker(
        markerId: MarkerId('fav_${loc.id}'),
        position: LatLng(loc.latitude, loc.longitude),
        infoWindow: InfoWindow(title: loc.name, snippet: 'ID: ${loc.id}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () => _showLocationDetails(loc),
      );
    }).toSet();
    if (_userMarker != null) markers.add(_userMarker!);
    return markers;
  }

  Future<void> _fitAllFavorites() async {
    final controller = await _controller.future;
    double minLat = favoriteLocations.first.latitude, maxLat = minLat;
    double minLng = favoriteLocations.first.longitude, maxLng = minLng;
    for (final l in favoriteLocations) {
      if (l.latitude < minLat) minLat = l.latitude;
      if (l.latitude > maxLat) maxLat = l.latitude;
      if (l.longitude < minLng) minLng = l.longitude;
      if (l.longitude > maxLng) maxLng = l.longitude;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    setState(() => _loadingLocation = true);
    try {
      // Get Current Location -> Latitude & Longitude -> Move Camera -> Show
      final position = await _locationService.getCurrentPosition();
      final target = LatLng(position.latitude, position.longitude);

      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)),
      );

      if (!mounted) return;
      setState(() {
        _locationGranted = true;
        _userMarker = Marker(
          markerId: const MarkerId('user_location'),
          position: target,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: 'You are here',
            snippet:
                '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
          ),
        );
      });
      _snack(
        'Lat: ${position.latitude.toStringAsFixed(5)}, '
        'Lng: ${position.longitude.toStringAsFixed(5)}',
      );
    } on LocationException catch (e) {
      if (!mounted) return;
      _showPermissionDialog(e);
    } catch (e) {
      _snack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPermissionDialog(LocationException e) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location problem'),
        content: Text(e.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (e.openAppSettings)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _locationService.openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          if (e.openLocationSettings)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _locationService.openLocationSettings();
              },
              child: const Text('Open Location Settings'),
            ),
        ],
      ),
    );
  }

  void _showLocationDetails(FavoriteLocation loc) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Favorite Location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('ID', '${loc.id}'),
            _detailRow('Name', loc.name),
            _detailRow('Latitude', '${loc.latitude}'),
            _detailRow('Longitude', '${loc.longitude}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );

  void _showFavoriteList() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '📍 Favorite Locations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: favoriteLocations.length,
                itemBuilder: (_, i) {
                  final loc = favoriteLocations[i];
                  return ListTile(
                    leading: const Text('⭐', style: TextStyle(fontSize: 22)),
                    title: Text(loc.name),
                    subtitle: Text('ID: ${loc.id}'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _moveToFavorite(loc);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moveToFavorite(FavoriteLocation loc) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 16),
      ),
    );
    await controller.showMarkerInfoWindow(MarkerId('fav_${loc.id}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places Map'),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        mapType: MapType.normal,
        markers: _markers,
        zoomControlsEnabled: true,
        myLocationEnabled: _locationGranted,
        myLocationButtonEnabled: false, // we use our own "My Location" button
        onMapCreated: (c) {
          if (!_controller.isCompleted) _controller.complete(c);
          Future.delayed(const Duration(milliseconds: 500), _fitAllFavorites);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fav_btn',
            onPressed: _showFavoriteList,
            icon: const Icon(Icons.star),
            label: const Text('📍 Favorite Locations'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'my_loc_btn',
            onPressed: _loadingLocation ? null : _goToMyLocation,
            icon: _loadingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: const Text('My Location'),
          ),
        ],
      ),
    );
  }
}
