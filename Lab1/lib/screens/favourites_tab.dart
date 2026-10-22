import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/book_list.dart';
import '../widgets/empty_state.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onFavourite,
    required this.onShowBooks,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onFavourite;
  final VoidCallback onShowBooks;

  @override
  Widget build(BuildContext context) {
    final favourites = books.where((book) => book.favourite).toList();
    favourites.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.meetingDate.compareTo(b.meetingDate);
    });
    return favourites.isEmpty
        ? EmptyState(
            icon: Icons.favorite_border,
            message: 'No favourite books yet.',
            buttonText: 'Browse books',
            onPressed: onShowBooks,
          )
        : BookList(books: favourites, onOpen: onOpen, onFavourite: onFavourite);
  }
}
