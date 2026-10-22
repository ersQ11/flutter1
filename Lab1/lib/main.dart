import 'package:flutter/material.dart';

import 'models/book.dart';
import 'routes.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_form_screen.dart';
import 'screens/shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final seed = ThemeData().colorScheme.primary;
    return MaterialApp(
      title: 'Reading Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => Shell(
          themeMode: _themeMode,
          onThemeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      },
      onGenerateRoute: (settings) {
        final arguments = settings.arguments;
        if (settings.name == Routes.detail && arguments is DetailArguments) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => BookDetailScreen(arguments: arguments),
          );
        }
        if (settings.name == Routes.form && arguments is FormArguments) {
          return MaterialPageRoute<Book>(
            settings: settings,
            builder: (context) => BookFormScreen(book: arguments.book),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: const Center(child: Text('Not found')),
        ),
      ),
    );
  }
}
