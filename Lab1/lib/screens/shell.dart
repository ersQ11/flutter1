import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/book.dart';
import '../models/profile.dart';
import '../routes.dart';
import 'books_tab.dart';
import 'favourites_tab.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Book> _books = seedBooks();
  Profile _profile = const Profile.empty();
  int _tab = 0;
  int _resetNumber = 0;

  void _selectTab(int index) {
    setState(() => _tab = index);
  }

  void _updateBook(Book changed) {
    setState(() {
      _books = _books
          .map((book) => book.id == changed.id ? changed : book)
          .toList();
    });
  }

  void _deleteBook(String id) {
    setState(() => _books = _books.where((book) => book.id != id).toList());
  }

  void _openBook(Book book) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArguments(
        book: book,
        profile: _profile,
        onChanged: _updateBook,
        onDeleted: _deleteBook,
        onSelectTab: _selectTab,
      ),
    );
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context)
        .pushNamed<Book>(Routes.form, arguments: const FormArguments());
    if (book == null || !mounted) return;
    setState(() => _books = [..._books, book]);
  }

  Future<void> _resetData() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Your books, loans, favourites and profile will be replaced with the starting data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (reset != true || !mounted) return;
    setState(() {
      _books = seedBooks();
      _profile = const Profile.empty();
      _tab = 0;
      _resetNumber++;
    });
  }

  @override
  Widget build(BuildContext context) {
    void favourite(Book book) =>
        _updateBook(book.copyWith(favourite: !book.favourite));

    return Scaffold(
      appBar: AppBar(
        title: Text(['Reading Club', 'Favourites', 'Profile'][_tab]),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Reading Club',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About Reading Club'),
                      content: const Text(
                        'Choose a book, borrow a copy and join a reading meeting. All data stays in memory during this session.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _resetData();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        key: ValueKey(_resetNumber),
        index: _tab,
        children: [
          BooksTab(books: _books, onOpen: _openBook, onFavourite: favourite),
          FavouritesTab(
            books: _books,
            onOpen: _openBook,
            onFavourite: favourite,
            onShowBooks: () => _selectTab(0),
          ),
          ProfileTab(
            profile: _profile,
            books: _books,
            onChanged: (profile) => setState(() => _profile = profile),
            themeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 2
          ? null
          : FloatingActionButton(
              onPressed: _addBook,
              tooltip: 'Add book',
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            label: 'Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
