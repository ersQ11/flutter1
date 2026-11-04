import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/cart_badge.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('three quantity changes: watch 3, actual select badge 0', (
    tester,
  ) async {
    final cart = Cart()..add(books[0]);
    addTearDown(cart.dispose);
    var watchBuilds = 0;
    var selectBuilds = 0;
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message == 'badge build') selectBuilds++;
    };
    addTearDown(() => debugPrint = original);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                _WatchBadge(onBuild: () => watchBuilds++),
                const CartBadge(),
              ],
            ),
          ),
        ),
      ),
    );
    watchBuilds = 0;
    selectBuilds = 0;
    for (var i = 0; i < 3; i++) {
      cart.increment(books[0]);
      await tester.pump();
    }
    original('SCOPE MEASUREMENT: watch=$watchBuilds select=$selectBuilds');
    expect(watchBuilds, 3);
    expect(selectBuilds, 0);
    expect(find.text('16800 ₸'), findsOneWidget);
    cart.remove(books[0]);
    await tester.pump();
    expect(selectBuilds, 1);
    debugPrint = original;
  });

  testWidgets('watch in a callback throws; read in build stays stale', (
    tester,
  ) async {
    final cart = Cart();
    addTearDown(cart.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: const MaterialApp(home: _WrongVerbs()),
      ),
    );
    await tester.tap(find.text('Wrong Add'));
    final exception = tester.takeException();
    expect(exception, isAssertionError);
    expect(
      exception.toString(),
      contains('Tried to listen to a value exposed with provider'),
    );
    // ignore: avoid_print
    print('WATCH ERROR: $exception');
    cart.add(books[0]);
    await tester.pump();
    expect(find.text('read count: 0'), findsOneWidget);
    expect(cart.count, 1);
    expect(tester.takeException(), isNull);
  });
}

class _WatchBadge extends StatelessWidget {
  const _WatchBadge({required this.onBuild});
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text('watch: ${context.watch<Cart>().count}');
  }
}

class _WrongVerbs extends StatelessWidget {
  const _WrongVerbs();

  @override
  Widget build(BuildContext context) {
    final n = context.read<Cart>().count; // deliberate experiment only
    return Scaffold(
      body: Column(
        children: [
          Text('read count: $n'),
          TextButton(
            onPressed: () => context.watch<Cart>().add(books[0]),
            child: const Text('Wrong Add'),
          ),
        ],
      ),
    );
  }
}
