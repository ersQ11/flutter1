import 'package:flutter/foundation.dart';

import 'book.dart';

class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  List<Book> get items => List.unmodifiable(_qty.keys);
  int get count => _qty.length;
  int get total =>
      _qty.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);

  int qtyOf(Book b) => _qty[b] ?? 0;

  bool add(Book b) {
    if (_qty.containsKey(b)) return false;
    _qty[b] = 1;
    notifyListeners();
    return true;
  }

  void remove(Book b) {
    _qty.remove(b);
    notifyListeners();
  }

  void increment(Book b) {
    if (!_qty.containsKey(b)) return;
    _qty[b] = _qty[b]! + 1;
    notifyListeners();
  }

  void decrement(Book b) {
    final quantity = _qty[b];
    if (quantity == null || quantity <= 1) return;
    _qty[b] = quantity - 1;
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
