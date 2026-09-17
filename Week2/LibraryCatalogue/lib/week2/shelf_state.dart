import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describeShelf(ShelfState state) {
  return switch(state) {
    Empty() => "Shelf is empty",
    Ready r => "Shelf is ready and has ${r.books.length} books",
    Broken b => "Shelf is broken: $b.message"
  };
}

({int count, double avgPages}) statsOf(List<Book> books) {
  if(books.isEmpty) return (count: 0, avgPages: 0.0);
  final totalPages = books.fold(0, (sum, b) => sum + b.pages);
  return (count: books.length, avgPages: totalPages / books.length);
}