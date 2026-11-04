import 'package:flutter/material.dart';

import 'cart_badge.dart';
import 'main.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({
    super.key,
    required this.cart,
    required this.total,
    required this.onAdd,
  });

  final List<Book> cart;
  final int total;
  final void Function(Book) onAdd;

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [CartBadge(count: cart.length, total: total)],
      ),
      body: ListView(children: [for (final b in books) _row(b)]),
    );
  }

  Widget _row(Book b) {
    debugPrint('row ${b.title}');
    return ListTile(
      title: Text(b.title),
      subtitle: Text('${b.author}\n${b.price} ₸'),
      isThreeLine: true,
      trailing: cart.contains(b)
          ? const Text('Added')
          : OutlinedButton(onPressed: () => onAdd(b), child: const Text('Add')),
    );
  }
}
