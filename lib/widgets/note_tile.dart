import 'package:flutter/material.dart';
import 'package:omnispace/models/omni_note.dart';

class NoteTile extends StatelessWidget {
  final OmniNote note;

  const NoteTile({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(note.subtitle),
    );
  }
}
