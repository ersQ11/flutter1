import 'package:flutter/material.dart';
import 'package:projects/data.dart';
import 'package:projects/profile_header.dart';
import 'package:projects/info_row.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Profile Screen",
      home: Scaffold(
        appBar: AppBar(title: const Text("My profile"), centerTitle: true),
        body: Column(
          children: [
            ProfileHeader(name: myName, university: myUniversity),
            for (final fact in facts)
              InfoRow(label: fact.label, value: fact.value),
          ],
        ),
      ),
    );
  }
}
