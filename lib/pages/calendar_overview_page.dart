// File: lib/pages/calendar_overview_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/help_button.dart';
import 'note_view_page.dart';

enum CalView { day, week, month, year }

class CalendarOverviewPage extends StatefulWidget {
  const CalendarOverviewPage({Key? key}) : super(key: key);

  @override
  State<CalendarOverviewPage> createState() => _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends State<CalendarOverviewPage> {
  CalView _view = CalView.day;
  DateTime _focusDate = DateTime.now();
  ZoneTheme? _realmFilter;
  bool _showEvents = true;
  bool _loading = true;

  List<OmniNote> _notes = [];
  List<Tracker> _events = [];

  final _noteSvc   = OmniNoteService.instance;
  final _trackSvc  = TrackerService.instance;
  final _spiritSvc = SpiritService.instance;
  final _deckSvc   = DeckService.instance;

  @override
  void initState() {
    super.initState();
    _trackSvc.init().then((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    _filterData();
    setState(() => _loading = false);
  }

  void _filterData() {
    final allNotes = _noteSvc.notes;
    final allEvents = _trackSvc.all.where((t) =>
      t.type == TrackerType.event && t.start != null).toList();

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

    _notes = allNotes.where((n) {
      final inDate = n.createdAt.isAfter(start) && n.createdAt.isBefore(end);
      final inRealm = _realmFilter == null || n.zone == _realmFilter;
      return inDate && inRealm;
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (_showEvents && (_realmFilter == null || _realmFilter == ZoneTheme.Fire)) {
      _events = allEvents.where((e) {
        final s = e.start!;
        return s.isAfter(start) && s.isBefore(end);
      }).toList()
        ..sort((a, b) => a.start!.compareTo(b.start!));
    } else {
      _events = [];
    }
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
      _filterData();
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
      _filterData();
    });
  }

  String _formatFocusLabel() {
    switch (_view) {
      case CalView.day:
        return DateFormat.yMMMd().format(_focusDate);
      case CalView.week:
        final s = _focusDate.subtract(const Duration(days: 3));
        final e = _focusDate.add(const Duration(days: 3));
        return '${DateFormat.MMMd().format(s)}–${DateFormat.MMMd().format(e)}';
      case CalView.month:
        return DateFormat.yMMMM().format(_focusDate);
      case CalView.year:
        return DateFormat.y().format(_focusDate);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _focusDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _focusDate = d;
        _filterData();
      });
    }
  }

  void _onRealmSelected(ZoneTheme? realm) {
    setState(() {
      _realmFilter = realm;
      _filterData();
    });
  }

  Future<void> _drawRealmSpirit() async {
    if (_realmFilter == null) return;
    final s = await _deckSvc.drawFromRealm(_realmFilter!);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All ${_realmFilter!.displayName} spirits already collected.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildRealmChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _realmFilter == null,
            onSelected: (_) => _onRealmSelected(null),
          ),
          const SizedBox(width: 8),
          ...ZoneTheme.values.map((realm) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(realm.icon, size: 20, color: Colors.deepPurple),
                label: Text(realm.displayName),
                selected: _realmFilter == realm,
                onSelected: (_) => _onRealmSelected(realm),
                selectedColor: Colors.deepPurple.shade100,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Master spirit for the active realm, if any
    Spirit? masterSpirit;
    if (_realmFilter != null) {
      final primaries = _spiritSvc.getPrimaries()
          .where((s) => s.realm == _realmFilter).toList();
      if (primaries.isNotEmpty) masterSpirit = primaries.first;
    }
    // Representative (collectible) spirits for the active realm
    final reps = _realmFilter != null
        ? _spiritSvc.getCollectibles().where((s) => s.realm == _realmFilter).toList()
        : <Spirit>[];

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: InkWell(
          onTap: _pickDate,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatFocusLabel()),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          HelpButton(
            helpTitle: 'Calendar Help',
            helpText: '''
• Tap the date to pick a specific day.  
• Use the arrows or toggle to navigate Day/Week/Month/Year.  
• Filter by realm to see only entries & spirits for that element.  
• Toggle events on/off to include tracker events.''',
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: () {
              setState(() {
                _focusDate = DateTime.now();
                _filterData();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRealmChips(),
          if (masterSpirit != null) ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(masterSpirit.realm.icon, size: 36, color: Colors.deepPurple),
                title: Text(masterSpirit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(masterSpirit.purpose),
              ),
            ),
            Wrap(
              spacing: 8,
              children: reps.map((s) {
                final inDeck = _deckSvc.deck.spiritIds.contains(s.id);
                return ChoiceChip(
                  avatar: Icon(s.realm.icon, size: 20, color: inDeck ? Colors.grey : Colors.white),
                  label: Text(s.name),
                  selected: false,
                  onSelected: inDeck ? null : (_) async {
                    await _deckSvc.draw(s);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${s.name} to deck!')),
                      );
                    }
                  },
                  backgroundColor: inDeck ? Colors.grey.shade300 : Colors.deepPurple,
                  labelStyle: TextStyle(color: inDeck ? Colors.black : Colors.white),
                );
              }).toList(),
            ),
            const Divider(),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ToggleButtons(
              isSelected: CalView.values.map((v) => v == _view).toList(),
              onPressed: (i) => setState(() {
                _view = CalView.values[i];
                _filterData();
              }),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Day')),
                Padding(padding: EdgeInsets.all(8), child: Text('Week')),
                Padding(padding: EdgeInsets.all(8), child: Text('Month')),
                Padding(padding: EdgeInsets.all(8), child: Text('Year')),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prev),
              Text(_formatFocusLabel(), style: Theme.of(context).textTheme.titleMedium),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _next),
            ],
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Show Events'),
            value: _showEvents,
            onChanged: (v) => setState(() {
              _showEvents = v;
              _filterData();
            }),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_notes.isEmpty && (!_showEvents || _events.isEmpty))
                    ? const Center(child: Text('No items in this range.'))
                    : ListView(
                        children: [
                          ..._notes.map((note) => ListTile(
                                title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
                                subtitle: Text(DateFormat.jm().format(note.createdAt)),
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => NoteViewPage(note: note)))
                                    .then((_) => _refresh()),
                              )),
                          if (_showEvents)
                            ..._events.map((e) => ListTile(
                                  leading: const Icon(Icons.event),
                                  title: Text(e.title.isNotEmpty ? e.title : '(Event)'),
                                  subtitle: Text(DateFormat.yMMMd().add_jm().format(e.start!)),
                                )),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: _realmFilter != null
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.filter_alt),
              label: Text('Draw ${_realmFilter!.displayName} Spirit'),
              onPressed: _drawRealmSpirit,
            )
          : null,
    );
  }
}
