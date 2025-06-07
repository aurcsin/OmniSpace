// lib/pages/calendar_overview_page.dart

import 'package:flutter/material.dart';
import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import 'note_detail_page.dart';

enum CalView { day, week, month, year }

class CalendarOverviewPage extends StatefulWidget {
  const CalendarOverviewPage({Key? key}) : super(key: key);

  @override
  _CalendarOverviewPageState createState() => _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends State<CalendarOverviewPage> {
  CalView _view = CalView.day;
  DateTime _focus = DateTime.now();
  List<OmniNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    final all = OmniNoteService.instance.notes;
    List<OmniNote> filtered;
    switch (_view) {
      case CalView.day:
        filtered = all.where((n) => _isSameDay(n.createdAt, _focus)).toList();
        break;
      case CalView.week:
        final start = _focus.subtract(const Duration(days: 3));
        final end = _focus.add(const Duration(days: 3));
        filtered = all.where((n) =>
            n.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            n.createdAt.isBefore(end.add(const Duration(seconds: 1)))).toList();
        break;
      case CalView.month:
        filtered = all
            .where((n) =>
                n.createdAt.year == _focus.year &&
                n.createdAt.month == _focus.month)
            .toList();
        break;
      case CalView.year:
        filtered =
            all.where((n) => n.createdAt.year == _focus.year).toList();
        break;
    }
    setState(() => _notes = filtered);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _onViewChange(CalView v) {
    setState(() => _view = v);
    _loadNotes();
  }

  void _moveFocus(int delta) {
    setState(() {
      switch (_view) {
        case CalView.day:
          _focus = _focus.add(Duration(days: delta));
          break;
        case CalView.week:
          _focus = _focus.add(Duration(days: 7 * delta));
          break;
        case CalView.month:
          final newMonth = _focus.month + delta;
          final newYear = _focus.year + ((newMonth - 1) ~/ 12);
          final monthNormalized = (newMonth - 1) % 12 + 1;
          final lastDay = DateTime(newYear, monthNormalized + 1, 0).day;
          final day = _focus.day.clamp(1, lastDay);
          _focus = DateTime(newYear, monthNormalized, day);
          break;
        case CalView.year:
          final newYear = _focus.year + delta;
          final lastDay = DateTime(newYear, _focus.month + 1, 0).day;
          final day = _focus.day.clamp(1, lastDay);
          _focus = DateTime(newYear, _focus.month, day);
          break;
      }
      _loadNotes();
    });
  }

  @override
  Widget build(BuildContext c) {
    final label = {
      CalView.day: '${_focus.year}-${_focus.month}-${_focus.day}',
      CalView.week: 'Week of ${_focus.year}-${_focus.month}-${_focus.day}',
      CalView.month: '${_focus.year}-${_focus.month.toString().padLeft(2, '0')}',
      CalView.year: '${_focus.year}',
    }[_view]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(children: [
        // View toggle
        ToggleButtons(
          isSelected: CalView.values.map((v) => v == _view).toList(),
          onPressed: (i) => _onViewChange(CalView.values[i]),
          children: const [
            Padding(padding: EdgeInsets.all(8), child: Text('Day')),
            Padding(padding: EdgeInsets.all(8), child: Text('Week')),
            Padding(padding: EdgeInsets.all(8), child: Text('Month')),
            Padding(padding: EdgeInsets.all(8), child: Text('Year')),
          ],
        ),

        // Focus controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left),
                       onPressed: () => _moveFocus(-1)),
            Text(label, style: Theme.of(c).textTheme.titleMedium),
            IconButton(icon: const Icon(Icons.chevron_right),
                       onPressed: () => _moveFocus(1)),
          ],
        ),

        const Divider(height: 1),

        // Notes list
        Expanded(
          child: _notes.isEmpty
              ? Center(child: Text('No notes for $label'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (_, i) {
                    final n = _notes[i];
                    return ListTile(
                      title:
                          Text(n.title.isNotEmpty ? n.title : '(No Title)'),
                      subtitle:
                          Text(TimeOfDay.fromDateTime(n.createdAt).format(c)),
                      onTap: () => Navigator.of(c)
                          .push(
                              MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: n)))
                          .then((_) => _loadNotes()),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
