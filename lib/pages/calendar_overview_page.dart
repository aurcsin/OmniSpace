// lib/pages/calendar_overview_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'note_detail_page.dart';

enum CalView { day, week, month, year }

class CalendarOverviewPage extends StatefulWidget {
  const CalendarOverviewPage({super.key});

  @override
  _CalendarOverviewPageState createState() => _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends State<CalendarOverviewPage> {
  CalView _view = CalView.day;
  DateTime _focusDate = DateTime.now();
  List<OmniNote> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    await OmniNoteService.instance.loadAllNotes();
    _filterNotes();
    setState(() => _loading = false);
  }

  void _filterNotes() {
    final all = OmniNoteService.instance.notes;
    DateTime start, end;
    switch (_view) {
      case CalView.day:
        start = DateTime(_focusDate.year, _focusDate.month, _focusDate.day);
        end = start.add(const Duration(days: 1));
        break;
      case CalView.week:
        start = _focusDate.subtract(const Duration(days: 3));
        end = _focusDate.add(const Duration(days: 4));
        break;
      case CalView.month:
        start = DateTime(_focusDate.year, _focusDate.month, 1);
        end = DateTime(_focusDate.year, _focusDate.month + 1, 1);
        break;
      case CalView.year:
        start = DateTime(_focusDate.year, 1, 1);
        end = DateTime(_focusDate.year + 1, 1, 1);
        break;
    }
    _notes = all.where((n) => n.createdAt.isAfter(start) && n.createdAt.isBefore(end)).toList();
  }

  void _prev() {
    setState(() {
      switch (_view) {
        case CalView.day:
          _focusDate = _focusDate.subtract(const Duration(days: 1));
          break;
        case CalView.week:
          _focusDate = _focusDate.subtract(const Duration(days: 7));
          break;
        case CalView.month:
          _focusDate = DateTime(_focusDate.year, _focusDate.month - 1, _focusDate.day);
          break;
        case CalView.year:
          _focusDate = DateTime(_focusDate.year - 1, _focusDate.month, _focusDate.day);
          break;
      }
      _filterNotes();
    });
  }

  void _next() {
    setState(() {
      switch (_view) {
        case CalView.day:
          _focusDate = _focusDate.add(const Duration(days: 1));
          break;
        case CalView.week:
          _focusDate = _focusDate.add(const Duration(days: 7));
          break;
        case CalView.month:
          _focusDate = DateTime(_focusDate.year, _focusDate.month + 1, _focusDate.day);
          break;
        case CalView.year:
          _focusDate = DateTime(_focusDate.year + 1, _focusDate.month, _focusDate.day);
          break;
      }
      _filterNotes();
    });
  }

  String _formatFocusLabel() {
    switch (_view) {
      case CalView.day:
        return DateFormat.yMMMd().format(_focusDate);
      case CalView.week:
        final start = _focusDate.subtract(const Duration(days: 3));
        final end = _focusDate.add(const Duration(days: 3));
        return '${DateFormat.MMMd().format(start)} – ${DateFormat.MMMd().format(end)}';
      case CalView.month:
        return DateFormat.yMMMM().format(_focusDate);
      case CalView.year:
        return DateFormat.y().format(_focusDate);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _focusDate = picked;
        _filterNotes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: InkWell(
          onTap: _pickDate,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatFocusLabel()),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: () {
              setState(() {
                _focusDate = DateTime.now();
                _filterNotes();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // View toggles
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ToggleButtons(
              isSelected: CalView.values.map((v) => v == _view).toList(),
              onPressed: (i) {
                setState(() {
                  _view = CalView.values[i];
                  _filterNotes();
                });
              },
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Day')),
                Padding(padding: EdgeInsets.all(8), child: Text('Week')),
                Padding(padding: EdgeInsets.all(8), child: Text('Month')),
                Padding(padding: EdgeInsets.all(8), child: Text('Year')),
              ],
            ),
          ),

          // Prev/Next controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prev),
              Text(
                _formatFocusLabel(),
                style: textTheme.titleMedium,
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _next),
            ],
          ),

          const Divider(),

          // Notes list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? const Center(child: Text('No notes in this range.'))
                    : ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (_, i) {
                          final note = _notes[i];
                          return ListTile(
                            title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
                            subtitle: Text(DateFormat.jm().format(note.createdAt)),
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                                .then((_) => _loadNotes()),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}