import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop/main.dart';

void main() {
  testWidgets('lifted state updates both routes and measures one Add', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lines = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) lines.add(message);
    };
    addTearDown(() => debugPrint = original);
    await tester.pumpWidget(const Shell());
    await tester.pumpAndSettle();
    lines.clear();
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    final screens = lines.where((line) => line == 'BooksScreen build').length;
    final rows = lines.where((line) => line.startsWith('row ')).length;
    original(
      'LIFTED MEASUREMENT: screen=$screens rows=$rows total=${screens + rows}',
    );
    expect(screens, 1);
    expect(rows, 6);
    expect(find.text('Added'), findsOneWidget);
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    expect(find.text('Total 7300 ₸'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove ${books[0].title}'));
    await tester.pumpAndSettle();
    expect(find.text('Total 3100 ₸'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsOneWidget);
    debugPrint = original;
  });
}
