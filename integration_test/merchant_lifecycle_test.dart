import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:clod/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End Merchant Lifecycle: Catalogue -> Customer -> POS', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Create a Product
    await tester.tap(find.text('Catalogue').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill product details
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Product');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '50.00',
    ); // Buying price
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '100.00',
    ); // Selling price
    await tester.enterText(find.byType(TextFormField).at(3), '10'); // Stock

    await tester.tap(find.text('Save Item'));
    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsWidgets);

    // 2. Create a Customer
    await tester.tap(find.text('Customers').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill customer details
    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), '555-1234');

    await tester.tap(find.text('Save Customer'));
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsWidgets);

    // 3. POS Checkout
    await tester.tap(find.text('POS').first);
    await tester.pumpAndSettle();

    // Tap on the product to add to cart
    await tester.tap(find.text('Test Product').first);
    await tester.pumpAndSettle();

    // Attach customer
    await tester.tap(find.byTooltip('Attach Customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('John Doe').first);
    await tester.pumpAndSettle();

    // Tap Checkout
    await tester.tap(find.text('Checkout').first);
    await tester.pumpAndSettle();

    // Confirm Payment
    await tester.tap(find.text('Cash').first);
    await tester.pumpAndSettle();

    // Should see success
    expect(find.text('Sale Complete!'), findsWidgets);
  });
}
