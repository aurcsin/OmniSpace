// lib/pages/spirit_detail_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/services/deck_service.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/widgets/help_button.dart';

class SpiritDetailPage extends StatefulWidget {
  final Spirit spirit;
  const SpiritDetailPage({Key? key, required this.spirit}) : super(key: key);

  @override
  State<SpiritDetailPage> createState() => _SpiritDetailPageState();
}

class _SpiritDetailPageState extends State<SpiritDetailPage> {
  final _deckSvc = DeckService.instance;
  final _spiritSvc = SpiritService.instance;

  bool get _inDeck =>
    _deckSvc.deck.any((s) => s.id == widget.spirit.id);

  Future<void> _toggleDeck() async {
    if (_inDeck) {
      await _deckSvc.remove(widget.spirit);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${widget.spirit.name} from your deck.')),
      );
    } else {
      await _deckSvc.draw(widget.spirit);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${widget.spirit.name} to your deck!')),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.spirit;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          HelpButton(
            helpTitle: 'Spirit Details',
            helpText: '''
• View the spirit’s archetype and purpose.  
• ${_inDeck ? 'Remove' : 'Add'} this spirit from/to your deck.  
• Your deck helps guide you in each realm.''',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Realm badge
            Row(
              children: [
                Icon(s.realm.icon, size: 32, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  s.realm.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Archetype
            Text(
              'Archetype',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              s.archetype,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Purpose / Description
            Text(
              'Purpose',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              s.purpose,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(_inDeck ? Icons.remove : Icons.add),
                label: Text(_inDeck ? 'Remove from Deck' : 'Add to Deck'),
                onPressed: _toggleDeck,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
