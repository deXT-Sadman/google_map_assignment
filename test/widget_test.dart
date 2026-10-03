// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:favorite_maps_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  testWidgets('favorite maps app renders the map and favorite locations',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FavoriteMapsApp());

    expect(find.text('Favorite Places Map'), findsOneWidget);
    expect(find.byType(GoogleMap), findsOneWidget);
    expect(find.text('My Location'), findsOneWidget);
    expect(find.text('📍 Favorite Locations'), findsOneWidget);

    await tester.tap(find.text('📍 Favorite Locations'));
    await tester.pumpAndSettle();

    expect(find.text('Khulna University'), findsOneWidget);
    expect(find.text('Khulna Railway Station'), findsOneWidget);
    expect(find.text('Shibbari More'), findsOneWidget);
    expect(find.text('Daulatpur Bus Stand'), findsOneWidget);
  });
}
