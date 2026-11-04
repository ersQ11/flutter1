import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final query = _search.text.trim().toLowerCase();
    final visibleBooks = books.where(
      (b) =>
          b.title.toLowerCase().contains(query) ||
          b.author.toLowerCase().contains(query),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Search books',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: visibleBooks.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView(
              children: [
                for (final b in visibleBooks)
                  _BookRow(key: ValueKey(b), book: b),
              ],
            ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final added = context.watch<Cart>().items.contains(book);

    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author}\n${book.price} ₸'),
      isThreeLine: true,
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(book);
                if (ok) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
