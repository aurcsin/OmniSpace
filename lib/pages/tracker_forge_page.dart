import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../services/tracker_service.dart';

/// Page for editing a tracker. Expects a tracker ID as argument.
class TrackerForgePage extends StatelessWidget {
  const TrackerForgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final trackerId = args is String ? args : null;
    final Tracker? tracker =
        trackerId != null ? TrackerService.instance.byId(trackerId) : null;

    if (tracker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tracker Forge')),
        body: const Center(child: Text('Tracker not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${tracker.title.isEmpty ? 'Tracker' : tracker.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${tracker.id}'),
            Text('Type: ${tracker.type.name}'),
          ],
        ),
      ),
    );
  }
}
