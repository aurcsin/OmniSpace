// File: lib/pages/studio_underwater_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import 'multi_pane_editor_page.dart';
import 'collections_page.dart';

class StudioUnderwaterPage extends StatelessWidget {
  const StudioUnderwaterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio • Underwater'),
      ),
      body: FutureBuilder<List<OmniNote>>(
        future: OmniNoteService.instance.all,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data!;
          final withMedia =
              notes.where((n) => n.attachments.isNotEmpty).toList();

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Media Attachments',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (withMedia.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No media yet.'),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: withMedia.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final n = withMedia[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)),
                        ),
                        child: Container(
                          width: 100,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 48),
                        ),
                      );
                    },
                  ),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.collections_bookmark),
                title: const Text('Browse Collections'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CollectionsPage()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
