import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/countdown.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.arguments});

  final DetailArguments arguments;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _book = widget.arguments.book;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _edit() async {
    final book = await Navigator.of(context)
        .pushNamed<Book>(Routes.form, arguments: FormArguments(book: _book));
    if (book == null || !mounted) return;
    widget.arguments.onChanged(book);
    setState(() => _book = book);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('Remove ${_book.title} from the club?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.arguments.onDeleted(_book.id);
    Navigator.pop(context);
  }

  void _showProfile() {
    widget.arguments.onSelectTab(2);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _borrowOrReturn() async {
    final name = widget.arguments.profile.name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Save your profile before borrowing.'),
          action: SnackBarAction(label: 'Profile', onPressed: _showProfile),
        ),
      );
      return;
    }
    final returning = _book.contains(name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(returning ? 'Return this book?' : 'Borrow this book?'),
        content: Text(
          returning
              ? 'Remove your name from the readers of ${_book.title}?'
              : 'Borrow one copy of ${_book.title} as $name?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(returning ? 'Return' : 'Borrow'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (!returning && _book.isFull) return;
    final readers = returning
        ? _book.readers.where((reader) => reader != name).toList()
        : [..._book.readers, name];
    final changed = _book.copyWith(readers: readers);
    widget.arguments.onChanged(changed);
    setState(() => _book = changed);
  }

  String _countdownText() =>
      switch (Countdown.forDate(_book.meetingDate, _now)) {
        Upcoming(:final duration) =>
          duration.inDays > 0
              ? 'In ${duration.inDays} days'
              : 'In ${duration.inHours}h ${duration.inMinutes % 60}m',
        Started(:final duration) => 'Started ${duration.inMinutes}m ago',
        Ended() => 'Meeting ended',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final description = _book.description;
    final (:taken, :free) = _book.places;
    final borrowed = _book.contains(widget.arguments.profile.name);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit();
                if (value == 'delete') _delete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/books.png',
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: _book.genre.color(scheme),
                  child: Icon(
                    _book.genre.icon,
                    size: 36,
                    color: scheme.onSurface,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: scheme.surface,
                    child: Text(_book.genre.label),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: scheme.surface,
                    child: Text(_countdownText()),
                  ),
                ),
              ],
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Readers ($taken)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        _book.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text('Meeting: ${formatMeeting(_book.meetingDate)}'),
                      const SizedBox(height: 12),
                      Text(
                        '${_book.online ? 'Meeting link' : 'Place'}: ${_book.place}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$taken borrowed · $free available · ${_book.copies} copies',
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 20),
                        Text(description),
                      ],
                    ],
                  ),
                  _book.readers.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Nobody has borrowed this book yet.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _book.readers.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final reader = _book.readers[index];
                            final you = reader == widget.arguments.profile.name;
                            return ListTile(
                              tileColor: you ? scheme.primaryContainer : null,
                              title: Text(you ? '$reader (You)' : reader),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: !borrowed && _book.isFull ? null : _borrowOrReturn,
              icon: Icon(borrowed ? Icons.assignment_return : Icons.menu_book),
              label: Text(
                borrowed
                    ? 'Return book'
                    : _book.isFull
                    ? 'No copies available'
                    : 'Borrow book',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
