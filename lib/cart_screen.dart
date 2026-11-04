import 'package:flutter/material.dart';

import 'main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});

  final List<Book> items;
  final void Function(Book) onRemove;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cart')),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final b in items)
                  ListTile(
                    title: Text(b.title),
                    subtitle: Text(b.author),
                    trailing: IconButton(
                      tooltip: 'Remove ${b.title}',
                      icon: const Icon(Icons.close),
                      onPressed: () => onRemove(b),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Total ${items.fold(0, (sum, b) => sum + b.price)} ₸'),
          ),
        ],
      ),
    ),
  );
}
