import 'models.dart';

class Library {
  final List<LibraryItem> _items = [];

  List<LibraryItem> get items => List.unmodifiable(_items);

  void add(LibraryItem item) => _items.add(item);

  Book? findByTitle(String bookTitle) {
    for(final item in _items){
      if (item is Book && item.title == bookTitle) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? "unknown";
  }

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? cachedReport;

  String generateReport() {
    return cachedReport ??= 'Library report generated at ${DateTime.now()}';
  }

  Iterable<String> get allTitles => _items.map((i) => (i.title));
  
  Iterable<Book> get booksAfter2010 =>
    _items.whereType<Book>().where((b) => b.year > 2010);

  double get averagePageCount {
    final books = _items.whereType<Book>();
    if (books.isEmpty) return 0.0;
    return books.fold(0, (sum, b) => sum + b.pages) / books.length;
  }

  Map<String, int> get booksByAuthor => _items.whereType<Book>().fold(
    <String, int>{}, (map, b) => map..[b.author.name] = (map[b.author.name] ?? 0) + 1);

  Set<String> get distinctAuthorNames =>
      _items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get presentGenres =>
      _items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> get displayList {
    final books = _items.whereType<Book>().toList();
    final hasIncompleteData = books.any((b) => b.pages == 0);

    return [
      'Catalogue: ',
      for (final book in books) "${book.title} (${book.year})",
      ...distinctAuthorNames,
      if (hasIncompleteData) "(IncompleteData)"
    ];
  }
}