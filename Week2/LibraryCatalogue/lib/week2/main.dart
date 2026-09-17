import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  Library library = Library();
  library.open();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  library.add(const Magazine(title: 'Home and beauty', year: 2026, issue: 432));
  library.add(const Ghost(title: 'Phantom Spec', year: 1995));

  print('Country of Clean Code: ${library.countryOf('Clean Code')}');
  print('Country of Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Country of Nonexistent: ${library.countryOf('Nonexistent')}');
  print('Library Opened At: ${library.openedAt}');
  print('Cached Report: ${library.generateReport()}');

  print('All titles: ${library.allTitles.toList()}');
  print('Books after 2010: ${library.booksAfter2010.map((b) => b.title).toList()}');
  print('Average page count: ${library.averagePageCount.toStringAsFixed(1)}');
  print('Author book counts: ${library.booksByAuthor}');
  print('Distinct authors: ${library.distinctAuthorNames}');
  print('Present genres: ${library.presentGenres}');

  print('\nDisplay List Literal Output:');
  for (final line in library.displayList) {
    print('  $line');
  }

  final allBooks = library.items.whereType<Book>().toList();
  final stats = statsOf(allBooks);
  print('Stats Record -> Count: ${stats.count}, Avg Pages: ${stats.avgPages}');

  print('\nShelf State Switch Expression Output:');
  print(describeShelf(Empty()));
  print(describeShelf(Ready(allBooks)));
  print(describeShelf(Broken('Shelf frame damaged')));
}