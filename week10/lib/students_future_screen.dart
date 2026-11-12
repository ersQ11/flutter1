import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/students_list.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key, this.api});

  final FakeApi? api;

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  late final _api = widget.api ?? FakeApi();
  late Future<List<Student>> _future;
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FutureBuilder'),
        actions: [
          IconButton(
            tooltip: 'Reload students',
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
          ),
          Switch(
            value: _compact,
            onChanged: (value) => setState(() => _compact = value),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        key: ValueKey(_future),
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorView(onRetry: _retry);
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final list = snapshot.data ?? const <Student>[];
          if (list.isEmpty) return const EmptyView();
          return StudentList(list, compact: _compact);
        },
      ),
    );
  }
}
