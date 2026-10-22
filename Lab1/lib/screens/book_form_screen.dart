import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/format.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Book _original;
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _copies;
  late final TextEditingController _description;
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _copiesFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  DateTime? _date;
  TimeOfDay? _time;
  Genre? _genre;
  bool _online = false;
  bool _saving = false;
  bool _allowPop = false;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _original = widget.book ?? Book.empty();
    _title = TextEditingController(text: _original.title);
    _place = TextEditingController(text: _original.place);
    _copies = TextEditingController(text: _original.copies.toString());
    _description = TextEditingController(text: _original.description ?? '');
    _genre = _original.genre;
    _online = _original.online;
    if (widget.book != null) {
      _date = DateUtils.dateOnly(_original.meetingDate);
      _time = TimeOfDay.fromDateTime(_original.meetingDate);
      _dateText.text = formatDate(_original.meetingDate);
      _timeText.text = formatTime(_original.meetingDate);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _copies.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _copiesFocus.dispose();
    _descriptionFocus.dispose();
    _dateFocus.dispose();
    _timeFocus.dispose();
    super.dispose();
  }

  DateTime? get _meeting {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool get _dirty {
    final initialMeeting = widget.book == null
        ? null
        : DateTime(
            _original.meetingDate.year,
            _original.meetingDate.month,
            _original.meetingDate.day,
            _original.meetingDate.hour,
            _original.meetingDate.minute,
          );
    return _title.text != _original.title ||
        _place.text != _original.place ||
        _copies.text != _original.copies.toString() ||
        _description.text != (_original.description ?? '') ||
        _genre != _original.genre ||
        _online != _original.online ||
        _meeting != initialMeeting ||
        (widget.book == null && (_date != null || _time != null));
  }

  void _refresh(String value) {
    setState(() {});
  }

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    return title.length < 3 || title.length > 60
        ? 'Use 3 to 60 characters'
        : null;
  }

  String? _validatePlace(String? value) {
    final place = (value ?? '').trim();
    if (place.isEmpty) {
      return _online ? 'Enter the meeting link' : 'Enter a meeting place';
    }
    if (_online && !place.contains('://')) return 'The link must contain ://';
    return null;
  }

  String? _validateCopies(String? value) {
    final copies = int.tryParse((value ?? '').trim());
    if (copies == null || copies < 1 || copies > 500) {
      return 'Enter a whole number from 1 to 500';
    }
    if (copies < _original.count) {
      return 'At least ${_original.count} copies are already borrowed';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (_date == null) return 'Choose a date';
    final meeting = _meeting;
    if (widget.book == null &&
        meeting != null &&
        !meeting.isAfter(DateTime.now())) {
      return 'Choose a future meeting';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (_time == null) return 'Choose a time';
    final meeting = _meeting;
    if (widget.book == null &&
        meeting != null &&
        !meeting.isAfter(DateTime.now())) {
      return 'Choose a future time';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? _original.meetingDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() {
      _date = date;
      _dateText.text = formatDate(date);
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.fromDateTime(_original.meetingDate),
    );
    if (time == null || !mounted) return;
    setState(() {
      _time = time;
      _timeText.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    if (_saving || _formKey.currentState?.validate() != true) return;
    final meeting = _meeting;
    final genre = _genre;
    final copies = int.tryParse(_copies.text.trim());
    if (meeting == null || genre == null || copies == null) return;
    final description = _description.text.trim();
    final book = _original.copyWith(
      title: _title.text.trim(),
      genre: genre,
      meetingDate: meeting,
      place: _place.text.trim(),
      copies: copies,
      online: _online,
      description: description,
      clearDescription: description.isEmpty,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.pop(context, book);
  }

  Future<void> _confirmDiscard() async {
    if (_saving || _asking) return;
    _asking = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _asking = false;
    if (discard != true) return;
    setState(() => _allowPop = true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => PopScope<Book>(
    canPop: _allowPop || (!_dirty && !_saving),
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _confirmDiscard();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add book' : 'Edit book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                enabled: !_saving,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Book title',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                onChanged: _refresh,
                validator: _validateTitle,
                onTapOutside: (_) => _titleFocus.unfocus(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Genre>(
                initialValue: _genre,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final genre in Genre.values)
                    DropdownMenuItem(value: genre, child: Text(genre.label)),
                ],
                onChanged: _saving
                    ? null
                    : (genre) => setState(() => _genre = genre),
                validator: (genre) => genre == null ? 'Choose a genre' : null,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online meeting'),
                value: _online,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _online = value ?? false),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _place,
                focusNode: _placeFocus,
                enabled: !_saving,
                decoration: InputDecoration(
                  labelText: _online ? 'Meeting link' : 'Meeting place',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _copiesFocus.requestFocus(),
                onChanged: _refresh,
                validator: _validatePlace,
                onTapOutside: (_) => _placeFocus.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _copies,
                focusNode: _copiesFocus,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Number of copies',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                onChanged: _refresh,
                validator: _validateCopies,
                onTapOutside: (_) => _copiesFocus.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateText,
                focusNode: _dateFocus,
                readOnly: true,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Meeting date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onTap: _pickDate,
                validator: _validateDate,
                onTapOutside: (_) => _dateFocus.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeText,
                focusNode: _timeFocus,
                readOnly: true,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Meeting time',
                  suffixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onTap: _pickTime,
                validator: _validateTime,
                onTapOutside: (_) => _timeFocus.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                onChanged: _refresh,
                validator: (_) => null,
                onTapOutside: (_) => _descriptionFocus.unfocus(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save book'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
