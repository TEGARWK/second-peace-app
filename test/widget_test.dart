import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secondpeacem/main.dart'; // Sesuaikan dengan nama package di pubspec.yaml

void main() {
  testWidgets('HomePage should display AppBar with title "Second Peace"', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SecondPeaceApp());

    expect(find.text('Second Peace'), findsOneWidget);
  });

  testWidgets('HomePage should contain a search field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SecondPeaceApp());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search Produk'), findsOneWidget);
  });

  testWidgets('HomePage should have shopping cart button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SecondPeaceApp());

    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
  });
}
