#!/usr/bin/env bash
# Usage: ./setup.sh YOUR_GOOGLE_MAPS_API_KEY
# Generates android/ios folders (if missing) and patches permissions + API key.
set -e
KEY="${1:-YOUR_GOOGLE_MAPS_API_KEY}"

if [ ! -d android ]; then
  flutter create . --project-name favorite_maps_app --org com.example --platforms android,ios
fi
flutter pub get

M=android/app/src/main/AndroidManifest.xml
if ! grep -q ACCESS_FINE_LOCATION "$M"; then
  sed -i.bak '0,/<application/s//<uses-permission android:name="android\.permission\.ACCESS_FINE_LOCATION"\/>\n    <uses-permission android:name="android\.permission\.ACCESS_COARSE_LOCATION"\/>\n    <uses-permission android:name="android\.permission\.INTERNET"\/>\n    <application/' "$M"
  sed -i.bak "0,/<\/application>/s//    <meta-data android:name=\"com.google.android.geo.API_KEY\" android:value=\"$KEY\"\/>\n    <\/application>/" "$M"
  rm -f "$M.bak"
fi

# minSdk 21+ is required by google_maps_flutter (Flutter default is usually fine).
P=ios/Runner/Info.plist
if [ -f "$P" ] && ! grep -q NSLocationWhenInUseUsageDescription "$P"; then
  sed -i.bak '0,/<dict>/s//<dict>\n\t<key>NSLocationWhenInUseUsageDescription<\/key>\n\t<string>This app needs your location to show it on the map.<\/string>/' "$P"
  rm -f "$P.bak"
fi
echo "Done. Now run: flutter run"
echo "iOS: also add GMSServices.provideAPIKey(\"$KEY\") in ios/Runner/AppDelegate.swift"
