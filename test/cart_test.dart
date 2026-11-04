import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  test('decrement updates total and stops at one without removing a book', () {
    final cart = Cart();
    addTearDown(cart.dispose);
    cart.add(books[0]);
    cart.increment(books[0]);
    var notifications = 0;
    cart.addListener(() => notifications++);
    cart.decrement(books[0]);
    expect(cart.qtyOf(books[0]), 1);
    expect(cart.total, 4200);
    expect(cart.count, 1);
    expect(notifications, 1);
    cart.decrement(books[0]);
    cart.decrement(books[1]);
    expect(cart.qtyOf(books[0]), 1);
    expect(cart.qtyOf(books[1]), 0);
    expect(cart.count, 1);
    expect(cart.total, 4200);
    expect(notifications, 1);
  });

  test('model works without a screen and rejects duplicates', () {
    final cart = Cart();
    addTearDown(cart.dispose);
    var notifications = 0;
    cart.addListener(() => notifications++);
    expect(cart.add(books[0]), isTrue);
    expect(cart.add(books[1]), isTrue);
    expect(cart.add(books[0]), isFalse);
    expect(notifications, 2);
    cart.remove(books[0]);
    expect(cart.count, 1);
    expect(cart.total, 3100);
    expect(notifications, 3);
    // No pumpWidget, runApp or BuildContext was needed.
    // ignore: avoid_print
    print('${cart.count} items, ${cart.total} ₸');
    expect(() => cart.items.add(books[0]), throwsUnsupportedError);
    expect(() => cart.items.clear(), throwsUnsupportedError);
    expect(cart.count, 1);
  });

  test(
    'quantities change total, not distinct count; remove removes the key',
    () {
      final cart = Cart();
      addTearDown(cart.dispose);
      cart.add(books[0]);
      cart.add(books[1]);
      cart.increment(books[0]);
      expect(cart.qtyOf(books[0]), 2);
      expect(cart.count, 2);
      expect(cart.total, 11500);
      cart.remove(books[0]);
      expect(cart.qtyOf(books[0]), 0);
      expect(cart.total, 3100);
      cart.increment(books[0]);
      expect(cart.count, 1);
      cart.clear();
      expect(cart.items, isEmpty);
      expect(cart.total, 0);
    },
  );
}
