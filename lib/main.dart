import 'package:flutter/material.dart';

import 'screens/map_screen.dart';

void main() {
  runApp(const FavoriteMapsApp());
}

class FavoriteMapsApp extends StatelessWidget {
  const FavoriteMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Places Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
