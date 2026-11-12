import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/students_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.api});

  final FakeApi api;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  late final _api = widget.api;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorView(onRetry: () => unawaited(_load()));
    }
    final students = _students;
    if (students == null) return const LoadingView();
    if (students.isEmpty) return const EmptyView();
    return StudentList(students);
  }

  @override
  Widget build(BuildContext context) {
    final students = _students;
    final loading = students == null && _error == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('By hand'),
        actions: [
          IconButton(
            tooltip: 'Reload students',
            onPressed: loading || _saving ? null : () => unawaited(_load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save',
        onPressed: students == null || _saving
            ? null
            : () async {
                if (_saving) return;
                final n = students.length;
                setState(() => _saving = true);
                try {
                  await _api.save(n);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                } on StateError catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error.message)));
                } finally {
                  if (mounted) setState(() => _saving = false);
                }
              },
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
      ),
    );
  }
}
