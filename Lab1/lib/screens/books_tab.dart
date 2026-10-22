import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/book_list.dart';
import '../widgets/empty_state.dart';

class BooksTab extends StatefulWidget {
  const BooksTab({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onFavourite;

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Genre? _genre;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _genre = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = widget.books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) &&
              (_genre == null || book.genre == _genre) &&
              (_showPast || !book.isPast),
        )
        .toList();
    visible.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.meetingDate.compareTo(b.meetingDate);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextFormField(
            controller: _search,
            focusNode: _searchFocus,
            validator: (_) => null,
            textInputAction: TextInputAction.search,
            onTapOutside: (_) => _searchFocus.unfocus(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Search books',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _genre == null,
                onSelected: (_) => setState(() => _genre = null),
              ),
              for (final genre in Genre.values)
                ChoiceChip(
                  avatar: Icon(genre.icon),
                  label: Text(genre.label),
                  selected: _genre == genre,
                  onSelected: (_) => setState(() => _genre = genre),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: FilterChip(
            label: const Text('Include past meetings'),
            selected: _showPast,
            onSelected: (value) => setState(() => _showPast = value),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No books match your search.',
                  buttonText: 'Clear filters',
                  onPressed: _clearFilters,
                )
              : BookList(
                  books: visible,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
