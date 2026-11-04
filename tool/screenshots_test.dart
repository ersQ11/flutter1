import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

// Run separately: flutter test tool/screenshots_test.dart
// Saves actual Flutter widget renders, not mockups or edited images.
void main() {
  testWidgets('capture Books and Cart at a phone size', (tester) async {
    tester.view.physicalSize = const Size(480, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      final sdk =
          Platform.environment['FLUTTER_ROOT'] ??
          const String.fromEnvironment('FLUTTER_SDK');
      if (sdk.isEmpty) {
        throw StateError('Set FLUTTER_ROOT to the Flutter SDK folder.');
      }
      final fonts = {
        'Roboto': Platform.isWindows
            ? '${Platform.environment['WINDIR']}/Fonts/segoeui.ttf'
            : '$sdk/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
        'MaterialIcons':
            '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      };
      for (final entry in fonts.entries) {
        final loader = FontLoader(entry.key);
        final bytes = await File(entry.value).readAsBytes();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
        await loader.load();
      }
    });

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: ChangeNotifierProvider(
          create: (_) => Cart(),
          child: const Shell(),
        ),
      ),
    );
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    ScaffoldMessenger.of(
      tester.element(find.byType(TextField)),
    ).clearSnackBars();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    await _save(tester, boundaryKey, 'screenshot_books.png');

    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase ${books[0].title}'));
    await tester.pumpAndSettle();
    expect(find.text('×2'), findsOneWidget);
    expect(find.text('11500 ₸'), findsOneWidget);
    await _save(tester, boundaryKey, 'screenshot_cart.png');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _save(WidgetTester tester, GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(name).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
