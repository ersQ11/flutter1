import 'package:flutter/material.dart';

enum Genre {
  fiction('Fiction', Icons.auto_stories),
  fantasy('Fantasy', Icons.castle),
  detective('Detective', Icons.search),
  science('Science', Icons.science),
  biography('Biography', Icons.person);

  const Genre(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    Genre.fiction => scheme.primaryContainer,
    Genre.fantasy => scheme.secondaryContainer,
    Genre.detective => scheme.tertiaryContainer,
    Genre.science => scheme.surfaceContainerHighest,
    Genre.biography => scheme.surfaceContainerHigh,
  };
}

class Book {
  factory Book({
    required String id,
    required String title,
    required Genre genre,
    required DateTime meetingDate,
    required String place,
    required int copies,
    List<String> readers = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) => Book._(
    List.unmodifiable(readers),
    id: id,
    title: title,
    genre: genre,
    meetingDate: meetingDate,
    place: place,
    copies: copies,
    online: online,
    description: description,
    favourite: favourite,
  );

  const Book._(
    this._readers, {
    required this.id,
    required this.title,
    required this.genre,
    required this.meetingDate,
    required this.place,
    required this.copies,
    this.online = false,
    this.description,
    this.favourite = false,
  });

  Book.empty()
    : id = DateTime.now().microsecondsSinceEpoch.toString(),
      title = '',
      genre = Genre.fiction,
      meetingDate = DateTime.now().add(const Duration(days: 1)),
      place = '',
      copies = 10,
      _readers = const [],
      online = false,
      description = null,
      favourite = false;

  final String id;
  final String title;
  final Genre genre;
  final DateTime meetingDate;
  final String place;
  final int copies;
  final List<String> _readers;
  final bool online;
  final String? description;
  final bool favourite;

  List<String> get readers => List.unmodifiable(_readers);
  int get count => _readers.length;
  int get free => copies - count;
  bool get isFull => count >= copies;
  bool get isPast => meetingDate.isBefore(DateTime.now());
  bool contains(String name) => _readers.any((reader) => reader == name);
  ({int taken, int free}) get places => (taken: count, free: free);

  Book copyWith({
    String? title,
    Genre? genre,
    DateTime? meetingDate,
    String? place,
    int? copies,
    List<String>? readers,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Book(
    id: id,
    title: title ?? this.title,
    genre: genre ?? this.genre,
    meetingDate: meetingDate ?? this.meetingDate,
    place: place ?? this.place,
    copies: copies ?? this.copies,
    readers: List.unmodifiable(readers ?? _readers),
    online: online ?? this.online,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
