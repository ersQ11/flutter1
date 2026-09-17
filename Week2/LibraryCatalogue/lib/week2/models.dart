enum Genre {
  craft("Hand made crafting"),
  theory("Graph theory"),
  unknown("Unknown");

  final String label;
  const Genre(this.label);

  static Genre fromString(String? raw){
    switch(raw?.toLowerCase()){
      case "craft":
        return Genre.craft;
      case "theory" :
        return Genre.theory;
      default:
        return Genre.unknown;
    }
  }
}

class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => 'Author (name: $name, country: ${country ?? "Unknown"})';
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  bool get isOld => DateTime.now().year - year > 20;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => "Borrow $title ($year)";
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    required this.description,
  });

  const Book.missing()
    : pages = 0,
      author = const Author(name: "Unknown"),
      genre = Genre.unknown,
      description = null,
      super(title: "Untitled", year: 0);

  factory Book.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Untitled';
    final year = json['year'] as int? ?? 0;
    final pages = json['pages'] as int? ?? 0;
    final authorName = json['author'] as String? ?? 'Unknown';
    final country = json['country'] as String?;
    final genre = json['genre'] as String?;
    final description = json['description'] as String?;

    return Book(
      title: title,
      year: year,
      pages: pages,
      author: Author(name: authorName, country: country),
      genre: Genre.fromString(genre),
      description: description,
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description
    );
  }

  @override
  String describe() => 'Book: "$title" ($year) was written by ${author.name}, has $pages pages';

  @override
  String toString() => 'title: $title, year: $year, pages: $pages, author: ${author.name}, genre: ${genre.name}';
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({ required super.title, required super.year, required this.issue});

  @override
  String describe() => 'Magazine: "$title" Issue #$issue ($year)';
}

class Ghost implements LibraryItem {
  @override
  final String title;
  @override
  final int year;

  const Ghost({required this.title, required this.year});

  @override
  String describe() => 'Ghost item: title: $title, year: $year';

  @override
  bool get isOld => DateTime.now().year - year > 20;
}