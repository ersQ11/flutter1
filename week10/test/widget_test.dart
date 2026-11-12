import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week10/api/fake_api.dart';
import 'package:week10/countdown_screen.dart';
import 'package:week10/main.dart';
import 'package:week10/students_future_screen.dart';
import 'package:week10/students_screen.dart';
import 'package:week10/widgets/students_list.dart';

class CountingApi extends FakeApi {
  int saves = 0;

  @override
  Future<void> save(int value) async {
    saves++;
    await super.save(value);
  }
}

Future<void> finishLoad(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pump();
}

Future<void> openScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              await Navigator.of(context)
                  .push<void>(MaterialPageRoute<void>(builder: (_) => screen));
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> closeScreen(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home opens all three exercises', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('By hand'), findsOneWidget);
    expect(find.text('FutureBuilder'), findsOneWidget);
    expect(find.text('Countdown'), findsOneWidget);
  });

  testWidgets('Manual loading, data, third-call error and retry', (
    tester,
  ) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: StudentsScreen(api: api)));
    expect(find.text('Loading students...'), findsOneWidget);
    await finishLoad(tester);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Reload students'));
      await tester.pump();
      await finishLoad(tester);
    }
    expect(find.text('Could not load students'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await finishLoad(tester);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(api.calls, 4);
  });

  for (final future in [false, true]) {
    testWidgets('Empty result is visible, FutureBuilder=$future', (
      tester,
    ) async {
      final api = FakeApi(empty: true);
      await tester.pumpWidget(
        MaterialApp(
          home: future
              ? StudentsFutureScreen(api: api)
              : StudentsScreen(api: api),
        ),
      );
      await finishLoad(tester);
      expect(find.text('No students yet'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  for (final fails in [false, true]) {
    testWidgets('Leaving pending manual request is safe, fails=$fails', (
      tester,
    ) async {
      final api = FakeApi()..calls = fails ? 2 : 0;
      await openScreen(tester, StudentsScreen(api: api));
      await closeScreen(tester);
      await finishLoad(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Save prevents double taps, pops on success and displays refusal',
    (tester) async {
      final api = CountingApi();
      await openScreen(tester, StudentsScreen(api: api));
      await finishLoad(tester);
      await tester.tap(find.byTooltip('Save'));
      await tester.tap(find.byTooltip('Save'));
      await tester.pump();
      expect(api.saves, 1);
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .onPressed,
        isNull,
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
      await tester.tap(find.text('Open'));
      await tester.pump();
      await finishLoad(tester);
      await tester.tap(find.byTooltip('Save'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.saves, 2);
      expect(find.text('server rejected 6'), findsOneWidget);
      expect(find.byType(StudentsScreen), findsOneWidget);
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('Leaving during save is safe', (tester) async {
    final api = CountingApi();
    await openScreen(tester, StudentsScreen(api: api));
    await finishLoad(tester);
    await tester.tap(find.byTooltip('Save'));
    await tester.pump();
    await closeScreen(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Switch keeps one Future; error can be retried', (tester) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: StudentsFutureScreen(api: api)));
    await finishLoad(tester);
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byType(Switch));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(api.calls, 1);
    expect(find.byType(StudentList), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Reload students'));
      await tester.pump();
      await finishLoad(tester);
    }
    expect(find.text('Could not load students'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Loading students...'), findsOneWidget);
    await finishLoad(tester);
    expect(find.byType(StudentList), findsOneWidget);
    expect(api.calls, 4);
  });

  for (final manual in [false, true]) {
    testWidgets('Countdown counts and cancels on Back, manual=$manual', (
      tester,
    ) async {
      final log = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) log.add(message);
      };
      addTearDown(() => debugPrint = original);
      await openScreen(tester, const CountdownScreen());
      if (manual) {
        await tester.tap(find.text('B: listen'));
        await tester.pump();
      }
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
      }
      expect(find.text('7'), findsOneWidget);
      await closeScreen(tester);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(log.where((line) => line == 'tick 6'), isEmpty);
      expect(tester.takeException(), isNull);
      debugPrint = original;
    });
  }

  testWidgets('Countdown reaches zero in both versions', (tester) async {
    for (final manual in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(home: CountdownScreen(key: ValueKey(manual))),
      );
      if (manual) {
        await tester.tap(find.text('B: listen'));
        await tester.pump();
      }
      for (var i = 0; i < 11; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
      }
      expect(find.text('0'), findsOneWidget);
    }
  });

  testWidgets('Required screenshots', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final bytes = await File('test/fonts/Roboto-Regular.ttf').readAsBytes();
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
      final iconBytes = await File('test/fonts/MaterialIcons-Regular.otf')
          .readAsBytes();
      final icons = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(iconBytes)));
      await icons.load();
    });
    const boundaryKey = ValueKey('screenshot');
    Widget frame(Widget home) => RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: home,
      ),
    );
    await tester.pumpWidget(frame(StudentsScreen(api: FakeApi()..calls = 2)));
    await finishLoad(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('../screenshot_error.png'),
    );
    await tester.pumpWidget(frame(const CountdownScreen()));
    await tester.tap(find.text('B: listen'));
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }
    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('../screenshot_countdown.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
