import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _manual = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('A: StreamBuilder')),
              ButtonSegment(value: true, label: Text('B: listen')),
            ],
            selected: {_manual},
            onSelectionChanged: (selection) {
              setState(() => _manual = selection.single);
            },
          ),
          Expanded(
            child: _manual
                ? const _ManualCountdown()
                : const _BuilderCountdown(),
          ),
        ],
      ),
    );
  }
}

class _BuilderCountdown extends StatefulWidget {
  const _BuilderCountdown();

  @override
  State<_BuilderCountdown> createState() => _BuilderCountdownState();
}

class _BuilderCountdownState extends State<_BuilderCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Center(
          child: Text(
            '${snapshot.data ?? 10}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        );
      },
    );
  }
}

class _ManualCountdown extends StatefulWidget {
  const _ManualCountdown();

  @override
  State<_ManualCountdown> createState() => _ManualCountdownState();
}

class _ManualCountdownState extends State<_ManualCountdown> {
  int _left = 10;
  late final StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((value) {
      setState(() => _left = value);
    });
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
