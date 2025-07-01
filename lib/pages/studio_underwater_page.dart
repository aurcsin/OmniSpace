import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import 'multi_pane_editor_page.dart';
import 'collections_page.dart';

class StudioUnderwaterPage extends StatefulWidget {
  const StudioUnderwaterPage({Key? key}) : super(key: key);
  @override
  State<StudioUnderwaterPage> createState() => _StudioUnderwaterPageState();
}

class _StudioUnderwaterPageState extends State<StudioUnderwaterPage> {
  final noteSvc   = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Water);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Studio spirits already in deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = spiritSvc.getPrimary(ZoneTheme.Water)!;
    final reps   = spiritSvc.forRealm(ZoneTheme.Water).where((s) => !s.isPrimary).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Studio • Underwater')),
      body: FutureBuilder<List<OmniNote>>(
        future: noteSvc.all,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data!;
          final mediaNotes = notes.where((n) => n.attachments.isNotEmpty).toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Master Spirit
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: Icon(master.realm.icon, size: 40, color: Colors.blue),
                  title: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(master.description),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: reps.map((s) {
                  final inDeck = deckSvc.deck.spiritIds.contains(s.id);
                  return ActionChip(
                    avatar: Icon(s.realm.icon, size: 20, color: inDeck ? Colors.grey : Colors.white),
                    label: Text(s.name),
                    backgroundColor: inDeck ? Colors.grey.shade300 : Colors.blueAccent,
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Notes with Media', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              if (mediaNotes.isEmpty)
                const Center(child: Text('No media notes yet.'))
              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mediaNotes.length,
                    separatorBuilder: (_,__)=>const SizedBox(width:8),
                    itemBuilder: (_,i){
                      final n = mediaNotes[i];
                      return GestureDetector(
                        onTap: ()=>Navigator.of(context).push(
                          MaterialPageRoute(builder: (_)=>MultiPaneEditorPage(n)),
                        ).then((_)=>setState((){})),
                        child: Container(
                          width: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size:48),
                        ),
                      );
                    }
                  ),
                ),

              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.collections_bookmark),
                title: const Text('Browse Collections'),
                onTap: ()=>Navigator.of(context).push(
                  MaterialPageRoute(builder: (_)=>const CollectionsPage()),
                ).then((_)=>setState((){})),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Studio Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
