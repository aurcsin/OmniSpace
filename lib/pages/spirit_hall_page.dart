import 'package:flutter/material.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'spirit_detail_page.dart';

class SpiritHallPage extends StatefulWidget {
  const SpiritHallPage({Key? key}) : super(key: key);

  @override
  State<SpiritHallPage> createState() => _SpiritHallPageState();
}

class _SpiritHallPageState extends State<SpiritHallPage> {
  final _spiritSvc = SpiritService.instance;
  String _search = '';

  // Fetch all spirits via the correct API:
  List<Spirit> get _all => _spiritSvc.getCollectibles();

  List<Spirit> get _filtered {
    final q = _search.toLowerCase().trim();
    return _all.where((s) {
      if (q.isEmpty) return true;
      return s.name.toLowerCase().contains(q) ||
             s.archetype.toLowerCase().contains(q) ||
             s.realm.displayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Group spirits by realm
    final byRealm = <ZoneTheme, List<Spirit>>{};
    for (var realm in ZoneTheme.values) {
      final spirits = _filtered.where((s) => s.realm == realm).toList();
      if (spirits.isNotEmpty) byRealm[realm] = spirits;
    }

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Spirit Hall'),
        actions: [
          HelpButton(
            helpTitle: 'Spirit Hall Help',
            helpText: '''
• Browse every spirit you’ve encountered.  
• Search by name, archetype, or realm.  
• Tap a spirit to view details or add to your deck.''',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search spirits…',
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No spirits match your search.'))
                : ListView(
                    children: byRealm.entries.map((entry) {
                      final realm = entry.key;
                      final spirits = entry.value;
                      return ExpansionTile(
                        leading: Icon(realm.icon, color: Colors.deepPurple),
                        title: Text('${realm.displayName} (${spirits.length})'),
                        children: spirits.map((s) {
                          return ListTile(
                            leading: Icon(realm.icon),
                            title: Text(s.name),
                            subtitle: Text(s.archetype),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SpiritDetailPage(spirit: s),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
