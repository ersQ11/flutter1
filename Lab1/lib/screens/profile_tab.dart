import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.books,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<Book> books;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onChanged(
      widget.profile.copyWith(
        name: _name.text.trim(),
        group: _group.text.trim(),
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final joined = widget.books.fold<int>(
      0,
      (total, book) => total + (book.contains(widget.profile.name) ? 1 : 0),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your reading profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your name before borrowing a book. Use the same name to find your loans.',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              focusNode: _nameFocus,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                _save();
                _groupFocus.requestFocus();
              },
              onTapOutside: (_) => _nameFocus.unfocus(),
              validator: (value) => (value ?? '').trim().length < 2
                  ? 'Enter at least 2 characters'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _group,
              focusNode: _groupFocus,
              decoration: const InputDecoration(
                labelText: 'Group',
                hintText: 'IT-2301',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              onTapOutside: (_) => _groupFocus.unfocus(),
              validator: (value) =>
                  RegExp(r'^[A-Za-z]{1,8}-\d{2,4}$')
                      .hasMatch((value ?? '').trim())
                  ? null
                  : 'Use a group like IT-2301',
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save profile')),
            const SizedBox(height: 24),
            Text(
              'You are on $joined lists',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in ThemeMode.values)
                  ChoiceChip(
                    label: Text(switch (mode) {
                      ThemeMode.system => 'System',
                      ThemeMode.light => 'Light',
                      ThemeMode.dark => 'Dark',
                    }),
                    selected: widget.themeMode == mode,
                    onSelected: (_) => widget.onThemeChanged(mode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
