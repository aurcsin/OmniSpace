// lib/pages/calendar_overview_page.dart

import 'dart:io'; // ← Add this line
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../services/omni_note_service.dart';
import 'note_detail_page.dart';

/// Four tabs: Day / Week / Month / Year.
/// Each tab provides its own toggles (Detailed vs. Snapshot, List vs. Grid, etc.).
enum CalendarView { day, week, month, year }

class CalendarOverviewPage extends StatefulWidget {
  @override
  _CalendarOverviewPageState createState() => _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends State<CalendarOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarView _selectedView = CalendarView.day;

  // --- Day view state ---
  bool _dayDetailed = true;

  // --- Week view state ---
  bool _weekListView = true;
  bool _weekCentered = true;
  DateTime _selectedWeekDate = DateTime.now();

  // --- Month view state ---
  bool _monthGridView = true;
  final int birthYear = 1900;
  late int _yearForMonth;
  late int _selectedMonth;

  // --- Year view state ---
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _yearForMonth = today.year;
    _selectedMonth = today.month;
    _selectedYear = today.year;

    _tabController = TabController(length: CalendarView.values.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedView = CalendarView.values[_tabController.index];
      });
    });

    OmniNoteService.instance.loadAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OmniNoteService>.value(
      value: OmniNoteService.instance,
      child: Consumer<OmniNoteService>(
        builder: (context, noteService, _) {
          final allNotes = noteService.notes;

          return Scaffold(
            appBar: AppBar(
              title: Text('Calendar Overview'),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: CalendarView.values.map((view) {
                  return Tab(text: _labelForView(view));
                }).toList(),
              ),
              actions: [
                if (_selectedView == CalendarView.day)
                  IconButton(
                    icon: Icon(_dayDetailed ? Icons.view_agenda : Icons.view_module),
                    tooltip: _dayDetailed ? 'Snapshot' : 'Detailed',
                    onPressed: () {
                      setState(() => _dayDetailed = !_dayDetailed);
                    },
                  ),
                if (_selectedView == CalendarView.week) ...[
                  IconButton(
                    icon: Icon(_weekListView ? Icons.grid_view : Icons.list),
                    tooltip: _weekListView ? 'Grid View' : 'List View',
                    onPressed: () {
                      setState(() => _weekListView = !_weekListView);
                    },
                  ),
                  IconButton(
                    icon: Icon(_weekCentered ? Icons.center_focus_strong : Icons.calendar_view_day),
                    tooltip: _weekCentered ? 'Centered' : 'Past/Future',
                    onPressed: () {
                      setState(() => _weekCentered = !_weekCentered);
                    },
                  ),
                ],
                if (_selectedView == CalendarView.month)
                  IconButton(
                    icon: Icon(_monthGridView ? Icons.view_agenda : Icons.view_comfy_alt),
                    tooltip: _monthGridView ? 'Summary' : 'Grid',
                    onPressed: () {
                      setState(() => _monthGridView = !_monthGridView);
                    },
                  ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: CalendarView.values.map((view) {
                switch (view) {
                  case CalendarView.day:
                    return _buildDayView(allNotes);
                  case CalendarView.week:
                    return _buildWeekView(allNotes);
                  case CalendarView.month:
                    return _buildMonthView(allNotes);
                  case CalendarView.year:
                    return _buildYearView(allNotes);
                }
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  String _labelForView(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return 'Day';
      case CalendarView.week:
        return 'Week';
      case CalendarView.month:
        return 'Month';
      case CalendarView.year:
        return 'Year';
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// DAY VIEW:
  ///   • Show all notes from *today*.
  ///   • Toggle Detailed vs. Snapshot via AppBar action.
  Widget _buildDayView(List<OmniNote> allNotes) {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final nextDay = dayStart.add(const Duration(days: 1));

    final todayNotes = allNotes.where((note) {
      return note.createdAt.isAfter(dayStart) && note.createdAt.isBefore(nextDay);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          DateFormat.yMMMd().format(today),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: _dayDetailed
              ? ListView.builder(
                  itemCount: todayNotes.length,
                  itemBuilder: (context, index) {
                    final note = todayNotes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          note.attachments.isEmpty
                              ? Icons.text_snippet
                              : _iconForAttachment(note.attachments.first.type),
                        ),
                        title: Text(
                          note.title.isNotEmpty ? note.title : '(No Title)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.subtitle.isNotEmpty) Text(note.subtitle),
                            if (note.content.isNotEmpty)
                              Text(
                                note.content.length > 60
                                    ? note.content.substring(0, 60) + '…'
                                    : note.content,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if ((note.tasks ?? []).isNotEmpty)
                                  const Icon(Icons.checklist, size: 14),
                                if ((note.goals ?? []).isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.flag, size: 14)
                                ],
                                if ((note.events ?? []).isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.event, size: 14)
                                ],
                                if (note.mood != null) ...[
                                  const SizedBox(width: 4),
                                  Chip(label: Text(note.mood!))
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: Text(
                          TimeOfDay.fromDateTime(note.createdAt).format(context),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                              .then((_) => OmniNoteService.instance.loadAllNotes());
                        },
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: todayNotes.length,
                  itemBuilder: (context, index) {
                    final note = todayNotes[index];
                    return ListTile(
                      leading: Icon(
                        note.attachments.isEmpty
                            ? Icons.text_snippet
                            : _iconForAttachment(note.attachments.first.type),
                      ),
                      title: Text(
                        note.recommendedTag ??
                            (note.content.isNotEmpty
                                ? (note.content.length > 20
                                    ? note.content.substring(0, 20) + '…'
                                    : note.content)
                                : '(No Content)'),
                      ),
                      trailing: Text(TimeOfDay.fromDateTime(note.createdAt).format(context)),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                            .then((_) => OmniNoteService.instance.loadAllNotes());
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// WEEK VIEW:
  ///   • Past/Future/Centered toggle.  • List vs. Grid toggle.
  ///   • Left/Right chevrons shift by 7 days.
  Widget _buildWeekView(List<OmniNote> allNotes) {
    final today = DateTime.now();
    DateTime start, end;

    if (_weekCentered) {
      start = _selectedWeekDate.subtract(const Duration(days: 3));
      end = _selectedWeekDate.add(const Duration(days: 3));
    } else if (_selectedWeekDate.isBefore(today)) {
      end = _selectedWeekDate;
      start = end.subtract(const Duration(days: 6));
    } else {
      start = _selectedWeekDate;
      end = start.add(const Duration(days: 6));
    }

    final weekNotes = allNotes.where((note) {
      final dt = note.createdAt;
      return dt.isAfter(DateTime(start.year, start.month, start.day).subtract(const Duration(seconds: 1))) &&
          dt.isBefore(DateTime(end.year, end.month, end.day).add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final daysList = List.generate(7, (i) => start.add(Duration(days: i)));

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedWeekDate = _selectedWeekDate.subtract(const Duration(days: 7));
                });
              },
            ),
            Text(
              _weekCentered
                  ? 'Centered: ${DateFormat.yMMMd().format(start)} – ${DateFormat.yMMMd().format(end)}'
                  : '${DateFormat.yMMMd().format(start)} – ${DateFormat.yMMMd().format(end)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedWeekDate = _selectedWeekDate.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),
        Expanded(
          child: _weekListView
              ? ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, idx) {
                    final day = daysList[idx];
                    final dayStart = DateTime(day.year, day.month, day.day);
                    final dayEnd = dayStart.add(const Duration(days: 1));
                    final notesForDay = weekNotes.where((note) {
                      return note.createdAt.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
                          note.createdAt.isBefore(dayEnd);
                    }).toList();

                    return ExpansionTile(
                      title: Text('${DateFormat.EEEE().format(day)} (${DateFormat.MMMd().format(day)})'),
                      trailing: Text('${notesForDay.length}'),
                      children: notesForDay.map((note) {
                        return ListTile(
                          leading: Icon(
                            note.attachments.isEmpty
                                ? Icons.text_snippet
                                : _iconForAttachment(note.attachments.first.type),
                          ),
                          title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
                          subtitle: Text(TimeOfDay.fromDateTime(note.createdAt).format(context)),
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                                .then((_) => OmniNoteService.instance.loadAllNotes());
                          },
                        );
                      }).toList(),
                    );
                  },
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: weekNotes.length,
                  itemBuilder: (context, idx) {
                    final note = weekNotes[idx];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                            .then((_) => OmniNoteService.instance.loadAllNotes());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                        ),
                        child: Center(
                          child: Icon(
                            note.attachments.isEmpty
                                ? Icons.text_snippet
                                : _iconForAttachment(note.attachments.first.type),
                            size: 36,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// MONTH VIEW:
  ///   • Year dropdown (birthYear…thisYear)
  ///   • Month dropdown (Jan…Dec)
  ///   • Toggle: Grid vs. Summary
  Widget _buildMonthView(List<OmniNote> allNotes) {
    final today = DateTime.now();
    final currentYear = today.year;
    final yearOptions = List.generate(currentYear - birthYear + 1, (i) => birthYear + i);

    final firstOfMonth = DateTime(_yearForMonth, _selectedMonth, 1);
    final lastOfMonth = DateTime(_yearForMonth, _selectedMonth + 1, 1).subtract(const Duration(days: 1));

    final firstWeekday = firstOfMonth.weekday % 7; // how many blank cells before the 1st
    final totalDays = lastOfMonth.day;

    // Build a 6×7 grid of DateTime? cells
    final matrix = List.generate(6, (r) => List<DateTime?>.filled(7, null));
    int dayCounter = 1;
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 7; c++) {
        final idx = r * 7 + c;
        if (idx >= firstWeekday && dayCounter <= totalDays) {
          matrix[r][c] = DateTime(_yearForMonth, _selectedMonth, dayCounter);
          dayCounter++;
        }
      }
    }

    // Group notes by date in that month
    final Map<DateTime, List<OmniNote>> notesByDate = {};
    for (var note in allNotes) {
      final dt = DateTime(note.createdAt.year, note.createdAt.month, note.createdAt.day);
      if (dt.year == _yearForMonth && dt.month == _selectedMonth) {
        notesByDate.putIfAbsent(dt, () => []).add(note);
      }
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _yearForMonth,
              items: yearOptions.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _yearForMonth = val;
                    if (_yearForMonth == today.year && _selectedMonth > today.month) {
                      _selectedMonth = today.month;
                    }
                  });
                }
              },
            ),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: _selectedMonth,
              items: List.generate(12, (i) => i + 1)
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(DateFormat.MMM().format(DateTime(_yearForMonth, m, 1))),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMonth = val);
                }
              },
            ),
            const Spacer(),
          ],
        ),
        if (_monthGridView)
          Expanded(
            child: Column(
              children: [
                // Weekday headers (Sun…Sat)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: List.generate(7, (i) {
                      final wd = DateFormat.E().format(DateTime(2021, 1, i + 3)); // Sun-Sat
                      return Expanded(
                        child: Center(
                            child:
                                Text(wd, style: const TextStyle(fontWeight: FontWeight.bold))),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: List.generate(6, (r) {
                      return Expanded(
                        child: Row(
                          children: List.generate(7, (c) {
                            final date = matrix[r][c];
                            if (date == null) {
                              return const Expanded(
                                child: SizedBox(),
                              );
                            }
                            final dayNotes = notesByDate[date] ?? [];
                            if (dayNotes.isEmpty) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text('${date.day}')),
                                ),
                              );
                            } else {
                              final firstNote = dayNotes.first;
                              Widget contentWidget;
                              if (firstNote.attachments.isNotEmpty &&
                                  firstNote.attachments.first.type == AttachmentType.image) {
                                contentWidget = ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.file(
                                    File(firstNote.attachments.first.localPath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                );
                              } else {
                                contentWidget = Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _showNotesForDate(date, dayNotes);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(child: contentWidget),
                                        Positioned(
                                          top: 4,
                                          left: 4,
                                          child: Text(
                                            '${date.day}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat.MMMM().format(DateTime(_yearForMonth, _selectedMonth, 1))} $_yearForMonth',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Notes: ${notesByDate.values.fold<int>(0, (sum, list) => sum + list.length)}',
                  ),
                  const SizedBox(height: 8),
                  Text('Top Moods:'),
                  ..._top3Moods(notesByDate).map((m) => Text('• $m')),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Show a bottom sheet listing all notes for a given date
  void _showNotesForDate(DateTime date, List<OmniNote> dayNotes) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Notes for ${DateFormat.yMMMd().format(date)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: dayNotes.length,
                  itemBuilder: (context, idx) {
                    final note = dayNotes[idx];
                    return ListTile(
                      leading: Icon(
                        note.attachments.isEmpty
                            ? Icons.text_snippet
                            : _iconForAttachment(note.attachments.first.type),
                      ),
                      title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
                      subtitle: Text(DateFormat.Hm().format(note.createdAt)),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                            .then((_) => OmniNoteService.instance.loadAllNotes());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// YEAR VIEW:
  ///   • Show a year dropdown (birthYear…thisYear).
  ///   • Underneath, list 12 ExpansionTiles (Jan…Dec) for that year.
  ///   • Each month tile shows “MonthName (n notes)”.  Expanding lists notes for that month.
  Widget _buildYearView(List<OmniNote> allNotes) {
    final today = DateTime.now();
    final currentYear = today.year;
    final yearOptions = List.generate(currentYear - birthYear + 1, (i) => birthYear + i);

    // Group notes by year → month
    final Map<int, Map<int, List<OmniNote>>> notesByYearMonth = {};
    for (var note in allNotes) {
      final y = note.createdAt.year;
      final m = note.createdAt.month;
      notesByYearMonth.putIfAbsent(y, () => {});
      notesByYearMonth[y]!.putIfAbsent(m, () => []);
      notesByYearMonth[y]![m]!.add(note);
    }

    final notesThisYear = notesByYearMonth[_selectedYear] ?? {};

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _selectedYear,
              items: yearOptions.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedYear = val);
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, idx) {
              final monthIdx = idx + 1;
              final monthName = DateFormat.MMMM().format(DateTime(_selectedYear, monthIdx, 1));
              final monthNotes = notesThisYear[monthIdx] ?? [];

              return ExpansionTile(
                title: Text('$monthName (${monthNotes.length} notes)'),
                children: [
                  if (monthNotes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      child: Text('(No notes this month)'),
                    )
                  else
                    Column(
                      children: monthNotes.map((note) {
                        return ListTile(
                          leading: Icon(
                            note.attachments.isEmpty
                                ? Icons.text_snippet
                                : _iconForAttachment(note.attachments.first.type),
                          ),
                          title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
                          subtitle: Text(DateFormat.MMMd().format(note.createdAt)),
                          onTap: () {
                            // Jump back to Month tab, focusing on this month/year:
                            setState(() {
                              _tabController.animateTo(CalendarView.month.index);
                              _yearForMonth = _selectedYear;
                              _selectedMonth = monthIdx;
                            });
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                                .then((_) => OmniNoteService.instance.loadAllNotes());
                          },
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForAttachment(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return Icons.image;
      case AttachmentType.audio:
        return Icons.mic;
      case AttachmentType.video:
        return Icons.videocam;
    }
  }

  /// Collates moods in `notesByDate` and returns the top 3 as strings “Mood (count)”.
  List<String> _top3Moods(Map<DateTime, List<OmniNote>> notesByDate) {
    final counter = <String, int>{};
    for (var notes in notesByDate.values) {
      for (var note in notes) {
        if (note.mood != null && note.mood!.isNotEmpty) {
          counter[note.mood!] = (counter[note.mood!] ?? 0) + 1;
        }
      }
    }
    final sorted = counter.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => '${e.key} (${e.value})').toList();
  }
}
