import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import 'multi_pane_editor_page.dart';

class SkySpacePage extends StatefulWidget {
  const SkySpacePage({Key? key}) : super(key: key);

  @override
  State<SkySpacePage> createState() => _SkySpacePageState();
}

class _SkySpacePageState extends State<SkySpacePage> {
  final noteSvc = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc  = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Air);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Sky spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = spiritSvc.getPrimary(ZoneTheme.Air)!;
    final reps   = spiritSvc.forRealm(ZoneTheme.Air)
        .where((s) => !s.isPrimary)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Sky • Space')),
      body: FutureBuilder<List<OmniNote>>(
        future: noteSvc.all,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data!
              .where((n) =>
                  n.zone == ZoneTheme.Air &&
                  !n.isArchived &&
                  !n.isTrashed)
              .toList()
            ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Master Spirit
              Card(
                color: Colors.lightBlue.shade50,
                child: ListTile(
                  leading: Icon(master.realm.icon, size: 40, color: Colors.blue),
                  title: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(master.description),
                ),
              ),

              // Representative spirits
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Other Spirits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Wrap(
                spacing: 8,
                children: reps.map((s) {
                  final inDeck = deckSvc.deck.spiritIds.contains(s.id);
                  return ActionChip(
                    avatar: Icon(s.realm.icon, size: 20, color: inDeck ? Colors.grey : Colors.white),
                    label: Text(s.name),
                    backgroundColor: inDeck ? Colors.grey.shade300 : Colors.deepPurple,
                    labelStyle: TextStyle(color: inDeck ? Colors.black : Colors.white),
                    onPressed: inDeck ? null : () async {
                      await deckSvc.draw(s);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${s.name} to deck!')),
                        );
                        setState(() {});
                      }
                    },
                  );
                }).toList(),
              ),

              const Divider(height: 32),

              // Notes list
              if (notes.isEmpty)
                const Center(child: Text('No Sky notes yet.'))
              else
                ...notes.map((n) {
                  return ListTile(
                    title: Text(n.title.isEmpty ? '(No title)' : n.title),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(n.lastUpdated)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)),
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Sky Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
