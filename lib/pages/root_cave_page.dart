import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import 'multi_pane_editor_page.dart';

class RootCavePage extends StatefulWidget {
  const RootCavePage({Key? key}) : super(key: key);
  @override
  State<RootCavePage> createState() => _RootCavePageState();
}

class _RootCavePageState extends State<RootCavePage> {
  final noteSvc   = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Void);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Root Cave spirits already in deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = spiritSvc.getPrimary(ZoneTheme.Void)!;
    final reps   = spiritSvc.forRealm(ZoneTheme.Void).where((s) => !s.isPrimary).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Root Cave • Underground')),
      body: FutureBuilder<List<OmniNote>>(
        future: noteSvc.all,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!;
          final archived = all.where((n) => n.isArchived && !n.isTrashed).toList();
          final trashed  = all.where((n) => n.isTrashed).toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Master Spirit
              Card(
                color: Colors.grey.shade200,
                child: ListTile(
                  leading: Icon(master.realm.icon, size: 40, color: Colors.grey),
                  title: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(master.description),
                ),
              ),
              const SizedBox(height:8),
              Wrap(
                spacing: 8,
                children: reps.map((s) {
                  final inDeck = deckSvc.deck.spiritIds.contains(s.id);
                  return ActionChip(
                    avatar: Icon(s.realm.icon, size:20, color: inDeck?Colors.grey:Colors.white),
                    label: Text(s.name),
                    backgroundColor: inDeck?Colors.grey.shade300:Colors.black54,
                    labelStyle: TextStyle(color: inDeck?Colors.black:Colors.white),
                    onPressed: inDeck?null:() async{
                      await deckSvc.draw(s);
                      if(mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${s.name} to deck!')),
                        );
                        setState((){});
                      }
                    },
                  );
                }).toList(),
              ),

              const Divider(height:32),
              const Padding(
                padding: EdgeInsets.symmetric(vertical:8),
                child: Text('Archived Entries', style: TextStyle(fontSize:16, fontWeight: FontWeight.w600)),
              ),
              if(archived.isEmpty)
                const Center(child: Text('No archived notes.'))
              else
                ...archived.map((n)=>ListTile(
                  title: Text(n.title.isEmpty?'(No title)':n.title),
                  onTap: ()=>Navigator.of(context).push(
                    MaterialPageRoute(builder:(_)=>MultiPaneEditorPage(n)),
                  ).then((_)=>setState((){})),
                )),
              const Divider(height:32),
              const Padding(
                padding: EdgeInsets.symmetric(vertical:8),
                child: Text('Trash', style: TextStyle(fontSize:16, fontWeight: FontWeight.w600)),
              ),
              if(trashed.isEmpty)
                const Center(child: Text('Trash is empty.'))
              else
                ...trashed.map((n)=>ListTile(
                  title: Text(n.title.isEmpty?'(No title)':n.title),
                  subtitle: const Text('Trashed'),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () async{
                      await noteSvc.restoreNote(n.id);
                      setState((){});
                    },
                  ),
                  onTap: ()=>Navigator.of(context).push(
                    MaterialPageRoute(builder:(_)=>MultiPaneEditorPage(n)),
                  ).then((_)=>setState((){})),
                )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Cave Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
