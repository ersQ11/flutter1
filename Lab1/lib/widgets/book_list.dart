import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_card.dart';

class BookList extends StatelessWidget {
  const BookList({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onFavourite;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      Widget card(int index) => BookCard(
        book: books[index],
        onOpen: () => onOpen(books[index]),
        onFavourite: () => onFavourite(books[index]),
      );

      if (constraints.maxWidth >= 600) {
        final columns = (constraints.maxWidth / 360).ceil();
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 200 * textScale,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) => card(index),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) => card(index),
      );
    },
  );
}
