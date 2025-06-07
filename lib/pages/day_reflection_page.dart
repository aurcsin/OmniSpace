// lib/pages/day_reflection_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/day_reflection.dart';
import '../services/day_reflection_service.dart';
import '../widgets/day_reflection_editor.dart';
import '../widgets/day_reflection_tile.dart';
import '../widgets/main_menu_drawer.dart';

class DayReflectionPage extends StatefulWidget {
  const DayReflectionPage({Key? key}) : super(key: key);

  @override
  _DayReflectionPageState createState() => _DayReflectionPageState();
}

class _DayReflectionPageState extends State<DayReflectionPage> {
  bool _loading = true;
  List<DayReflection> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DayReflectionService.instance.init();
    setState(() {
      _items = DayReflectionService.instance.reflections;
      _loading = false;
    });
  }

  void _edit(DayReflection? existing) {
    showDialog(
      context: context,
      builder: (_) => DayReflectionEditor(
        existing: existing,                    // use the existing param
        onSave: (text) async {
          final key = existing?.dateKey ??
              DateFormat('yyyy-MM-dd').format(DateTime.now());
          final reflection = existing != null
              ? existing
              : DayReflection(dateKey: key);

          reflection.summary = text;           // write into summary

          await DayReflectionService.instance.saveReflection(reflection);
          Navigator.of(context).pop();         // close the dialog
          _load();                             // refresh list
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Day Reflections')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No reflections yet.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final r = _items[i];
                    return DayReflectionTile(
                      reflection: r,
                      onEdit: () => _edit(r),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
