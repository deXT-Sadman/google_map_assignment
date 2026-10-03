# Favorite Places Map (Flutter Assignment)

Flutter app with Google Maps, current location (geolocator), favorite-location markers,
marker details bottom sheet and a favorite locations list.

## Features
- Google Map with zoom controls, custom **My Location** button
- Real device location via `geolocator` (not hard-coded) with permission handling
  (denied, permanently denied, GPS off)
- 4 favorite locations as markers (model: `id`, `name`, `latitude`, `longitude`)
- Tap marker -> bottom sheet with ID, name, latitude, longitude
- **📍 Favorite Locations** button -> list; tap item -> camera moves there

## Project structure
```
lib/
  main.dart
  models/favorite_location.dart
  services/location_service.dart
  screens/map_screen.dart
```

## Setup
1. Get a Google Maps API key (enable **Maps SDK for Android** / **Maps SDK for iOS**)
   at https://console.cloud.google.com/
2. Run (Linux/macOS/Git Bash):
   ```
   ./setup.sh YOUR_GOOGLE_MAPS_API_KEY
   ```
   This runs `flutter create .`, `flutter pub get`, and patches the Android manifest
   (location + internet permissions, API key) and iOS Info.plist.

   **Manual alternative (Windows):**
   ```
   flutter create . --project-name favorite_maps_app --platforms android,ios
   flutter pub get
   ```
   Then in `android/app/src/main/AndroidManifest.xml`, before `<application>` add:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
   and inside `<application>` add:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```
   iOS: add `NSLocationWhenInUseUsageDescription` to `Info.plist` and
   `GMSServices.provideAPIKey("YOUR_KEY")` in `AppDelegate.swift`.
3. `flutter run` on a real device or emulator (set a location in emulator settings).


