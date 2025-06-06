import 'package:flutter/material.dart';
import 'package:omnispace/pages/time_group_journal_page.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TimeGroupJournalPage(),
    );
  }
}
