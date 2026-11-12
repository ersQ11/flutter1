import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Students Async',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = FakeApi();

  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice 10')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Students Async',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async => await _open(StudentsScreen(api: _api)),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async => await _open(const StudentsFutureScreen()),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async => await _open(const CountdownScreen()),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
