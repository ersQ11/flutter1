import 'package:flutter/material.dart';

import 'models/book.dart';
import 'models/profile.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/book';
  static const form = '/book-form';
}

class DetailArguments {
  const DetailArguments({
    required this.book,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onSelectTab,
  });

  final Book book;
  final Profile profile;
  final ValueChanged<Book> onChanged;
  final ValueChanged<String> onDeleted;
  final ValueChanged<int> onSelectTab;
}

class FormArguments {
  const FormArguments({this.book});

  final Book? book;
}
