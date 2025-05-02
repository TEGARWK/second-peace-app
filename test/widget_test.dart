import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secondpeacem/main.dart';

void main() {
  group('HomePage Widget Tests', () {
    // Setup: render SecondPeaceApp dengan isLoggedIn false
    Future<void> _pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SecondPeaceApp(isLoggedIn: false)),
      );
    }

    testWidgets('Menampilkan AppBar dengan judul "Second Peace"', (
      tester,
    ) async {
      await _pumpApp(tester);

      expect(find.text('Second Peace'), findsOneWidget);
    });

    testWidgets('Menampilkan field pencarian produk', (tester) async {
      await _pumpApp(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.text('Search Produk'),
        findsOneWidget,
      ); // Ganti jika placeholder berbeda
    });

    testWidgets('Menampilkan tombol keranjang belanja', (tester) async {
      await _pumpApp(tester);

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });
  });
}
