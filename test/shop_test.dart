import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('add, quantity, remove, search and confirmed clear', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsNWidgets(3)); // two rows + SnackBar
    expect(find.text('2'), findsOneWidget);
    ScaffoldMessenger.of(
      tester.element(find.byType(TextField)),
    ).clearSnackBars();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase ${books[0].title}'));
    await tester.pumpAndSettle();
    expect(find.text('×2'), findsOneWidget);
    expect(find.text('11500 ₸'), findsOneWidget);
    await tester.tap(find.byTooltip('Hide total'));
    await tester.pumpAndSettle();
    expect(find.text('11500 ₸'), findsNothing);
    await tester.tap(find.byTooltip('Show total'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove ${books[1].title}'));
    await tester.pumpAndSettle();
    expect(find.text('8400 ₸'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'null safety');
    await tester.pumpAndSettle();
    expect(find.text(books[1].title), findsOneWidget);
    expect(find.text(books[0].title), findsNothing);
    expect(find.text('Add'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no matching book');
    await tester.pumpAndSettle();
    expect(find.text('No books found'), findsOneWidget);
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('×2'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('0 ₸'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
