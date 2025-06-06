// lib/pages/calendar_overview_page.dart

import 'dart:io'; // for File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/attachment.dart';          // for AttachmentType
import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import 'note_detail_page.dart';

enum CalendarView { day, week, month, year }

class CalendarOverviewPage extends StatefulWidget {
  @override
  _CalendarOverviewPageState createState() =>
      _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends State<CalendarOverviewPage>
    with SingleTickerProviderStateMixin {
  bool _listView = true; // toggle between List and Grid
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // We only need the controller to switch tabs; no need to store the selected tab in a separate field.
    _tabController = TabController(
      length: CalendarView.values.length,
      vsync: this,
    );
    // Load notes initially
    OmniNoteService.instance.loadAllNotes();
  }

  List<OmniNote> _notes = [];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OmniNoteService>.value(
      value: OmniNoteService.instance,
      child: Consumer<OmniNoteService>(
        builder: (context, noteService, _) {
          _notes = noteService.notes;
          return Scaffold(
            appBar: AppBar(
              title: Text('Calendar Overview'),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: CalendarView.values.map((view) {
                  final label = _labelForView(view);
                  return Tab(text: label);
                }).toList(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _listView ? Icons.grid_view : Icons.list,
                  ),
                  tooltip: _listView ? 'Switch to Grid' : 'Switch to List',
                  onPressed: () {
                    setState(() {
                      _listView = !_listView;
                    });
                  },
                ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: CalendarView.values.map((view) {
                switch (view) {
                  case CalendarView.day:
                    return _buildDayView();
                  case CalendarView.week:
                    return _buildWeekView();
                  case CalendarView.month:
                    return _buildMonthView();
                  case CalendarView.year:
                    return _buildYearView();
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

  /// --------------------- DAY VIEW ---------------------
  /// Shows a chronological list of notes from *today*.
  Widget _buildDayView() {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final dayEnd = dayStart.add(Duration(days: 1));

    final todayNotes = _notes.where((note) {
      return note.createdAt.isAfter(dayStart) &&
          note.createdAt.isBefore(dayEnd);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _listView
        ? ListView.builder(
            itemCount: todayNotes.length,
            itemBuilder: (context, index) {
              final note = todayNotes[index];
              return ListTile(
                leading: Icon(
                  note.attachments.isEmpty
                      ? Icons.description
                      : _iconForAttachment(
                          note.attachments.first.type),
                ),
                title:
                    Text(note.title.isNotEmpty ? note.title : 'Untitled'),
                subtitle: Text(
                  DateFormat.Hm().format(note.createdAt),
                ),
                trailing: _dailyBriefStats(note),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NoteDetailPage(omniNote: note),
                    ),
                  );
                },
              );
            },
          )
        : _buildGridOfNotes(todayNotes);
  }

  /// --------------------- WEEK VIEW ---------------------
  /// Shows notes for the current week (Sunday–Saturday).
  Widget _buildWeekView() {
    final today = DateTime.now();
    // Find Sunday of this week (weekday % 7 == 0 → Sunday)
    final int weekday = today.weekday; // Monday=1 … Sunday=7
    final sunday = today.subtract(Duration(days: weekday % 7));
    final saturday = sunday.add(Duration(days: 6));

    final weekNotes = _notes.where((note) {
      return note.createdAt.isAfter(sunday) &&
          note.createdAt
              .isBefore(saturday.add(Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_listView) {
      // Group by date (e.g. Sunday, Monday, …)
      final grouped = <DateTime, List<OmniNote>>{};
      for (var n in weekNotes) {
        final dt = DateTime(n.createdAt.year,
            n.createdAt.month, n.createdAt.day);
        grouped.putIfAbsent(dt, () => []).add(n);
      }

      final sortedDates = grouped.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      return ListView.builder(
        itemCount: sortedDates.length,
        itemBuilder: (context, idx) {
          final date = sortedDates[idx];
          final notesForDate = grouped[date]!;
          final dayLabel =
              DateFormat.EEEE().format(date); // e.g. “Sunday”
          return ExpansionTile(
            title:
                Text('$dayLabel (${DateFormat.MMMd().format(date)})'),
            trailing: Text('${notesForDate.length}'),
            children: notesForDate.map((note) {
              return ListTile(
                leading: Icon(
                  note.attachments.isEmpty
                      ? Icons.description
                      : _iconForAttachment(
                          note.attachments.first.type),
                ),
                title: Text(
                    note.title.isNotEmpty ? note.title : 'Untitled'),
                subtitle: Text(
                    DateFormat.Hm().format(note.createdAt)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NoteDetailPage(omniNote: note),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      );
    } else {
      return _buildGridOfNotes(weekNotes);
    }
  }

  /// --------------------- MONTH VIEW ---------------------
  /// Displays a grid of week‐rows and day‐cells. Each cell shows a dot or thumbnail.
  Widget _buildMonthView() {
    final today = DateTime.now();
    final year = today.year;
    final month = today.month;
    final firstOfMonth = DateTime(year, month, 1);
    final lastOfMonth =
        DateTime(year, month + 1, 1).subtract(Duration(days: 1));

    // Build a calendar grid with 6 rows × 7 columns
    final firstWeekday = firstOfMonth.weekday; // Monday=1…Sunday=7
    final dayOffset = (firstWeekday % 7); // blanks before day 1
    final totalDays = lastOfMonth.day;

    // Build a 6×7 matrix: each cell is DateTime? (null if blank)
    final matrix =
        List.generate(6, (r) => List<DateTime?>.filled(7, null));
    int dayCounter = 1;
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 7; c++) {
        final globalIndex = r * 7 + c;
        if (globalIndex >= dayOffset && dayCounter <= totalDays) {
          matrix[r][c] = DateTime(year, month, dayCounter);
          dayCounter++;
        }
      }
    }

    // Group notes by date
    final Map<DateTime, List<OmniNote>> notesByDate = {};
    for (var n in _notes) {
      final dt = DateTime(n.createdAt.year,
          n.createdAt.month, n.createdAt.day);
      if (dt.year == year && dt.month == month) {
        notesByDate.putIfAbsent(dt, () => []).add(n);
      }
    }

    // Build calendar UI
    return Column(
      children: [
        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: List.generate(7, (i) {
              final wd =
                  DateFormat.E().format(DateTime(2021, 1, i + 3));
              return Expanded(
                child: Center(
                  child: Text(
                    wd,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
        ),
        // 6 rows
        Expanded(
          child: Column(
            children: List.generate(6, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(7, (c) {
                    final date = matrix[r][c];
                    if (date == null) {
                      return Expanded(child: Container());
                    }

                    final dayNotes = notesByDate[date] ?? [];
                    if (dayNotes.isEmpty) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Optional: tap blank day to create a new note
                          },
                          child: Container(
                            margin: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade100,
                            ),
                            child: Center(
                              child: Text('${date.day}'),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Show thumbnail if first attachment is image
                      final first = dayNotes.first;
                      Widget cellContent;
                      if (first.attachments.isNotEmpty &&
                          first.attachments.first.type ==
                              AttachmentType.image) {
                        cellContent = ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(first.attachments.first.localPath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      } else {
                        // Fallback: a colored dot
                        cellContent = Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
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
                            margin: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade50,
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(child: cellContent),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
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
    );
  }

  /// --------------------- YEAR VIEW ---------------------
  /// Displays a grid of 12 months with note/attachment counts.
  Widget _buildYearView() {
    final today = DateTime.now();
    final year = today.year;

    // Group notes by month
    final Map<int, List<OmniNote>> notesByMonth = {};
    for (var n in _notes) {
      if (n.createdAt.year == year) {
        final m = n.createdAt.month;
        notesByMonth.putIfAbsent(m, () => []).add(n);
      }
    }

    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, idx) {
        final monthIndex = idx + 1; // 1 = Jan, … 12 = Dec
        final monthNotes = notesByMonth[monthIndex] ?? [];
        final totalAttachments = monthNotes.fold<int>(
          0,
          (sum, n) => sum + n.attachments.length,
        );
        return GestureDetector(
          onTap: () {
            // Optional: navigate to Month view for this month
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.MMM().format(DateTime(year, monthIndex, 1)),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('${monthNotes.length} Notes'),
                Text('$totalAttachments Attachments'),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Display a bottom sheet listing all notes for a given date
  void _showNotesForDate(DateTime date, List<OmniNote> dayNotes) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Notes for ${DateFormat.yMMMd().format(date)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: dayNotes.length,
                  itemBuilder: (context, idx) {
                    final note = dayNotes[idx];
                    return ListTile(
                      leading: Icon(
                        note.attachments.isEmpty
                            ? Icons.description
                            : _iconForAttachment(
                                note.attachments.first.type),
                      ),
                      title: Text(
                        note.title.isNotEmpty ? note.title : 'Untitled',
                      ),
                      subtitle: Text(
                        DateFormat.Hm().format(note.createdAt),
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) =>
                                NoteDetailPage(omniNote: note),
                          ),
                        )
                            .then(
                          (_) => OmniNoteService.instance.loadAllNotes(),
                        );
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

  /// Build a grid of note cards (used in various views)
  Widget _buildGridOfNotes(List<OmniNote> notesList) {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: notesList.length,
      itemBuilder: (context, idx) {
        final note = notesList[idx];
        return _CalendarNoteCard(
          note: note,
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) =>
                    NoteDetailPage(omniNote: note),
              ),
            )
                .then(
              (_) => OmniNoteService.instance.loadAllNotes(),
            );
          },
        );
      },
    );
  }

  /// Small stats widget for a single note (e.g. #attachments)
  Widget _dailyBriefStats(OmniNote note) {
    final attachCount = note.attachments.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (attachCount > 0)
          Icon(Icons.attach_file, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text('$attachCount'),
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
}

/// A small “card” widget used in Month View and Year View grids
class _CalendarNoteCard extends StatelessWidget {
  final OmniNote note;
  final VoidCallback onTap;
  const _CalendarNoteCard({
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final first = note.attachments.isNotEmpty
        ? note.attachments.first
        : null;
    Widget content;
    if (first != null && first.type == AttachmentType.image) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(first.localPath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
        ),
        child: Center(
          child: Icon(
            first == null
                ? Icons.description
                : (first.type == AttachmentType.audio
                    ? Icons.mic
                    : Icons.videocam),
            color: Colors.grey.shade600,
            size: 32,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child:
          ClipRRect(borderRadius: BorderRadius.circular(8), child: content),
    );
  }
}
