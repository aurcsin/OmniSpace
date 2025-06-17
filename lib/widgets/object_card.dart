import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../models/tracker.dart';
import '../models/project.dart';

/// A universal card widget that can display a [OmniNote], [Tracker],
/// or [Project] in a simple, uniform style.
class ObjectCard extends StatelessWidget {
  final OmniNote? note;
  final Tracker? tracker;
  final Project? project;
  const ObjectCard({super.key, this.note, this.tracker, this.project});

  @override
  Widget build(BuildContext context) {
    if (note != null) return _buildNote(context, note!);
    if (tracker != null) return _buildTracker(context, tracker!);
    if (project != null) return _buildProject(context, project!);
    return const SizedBox.shrink();
  }

  Widget _buildNote(BuildContext context, OmniNote n) {
    final hasImage = n.attachments.any((a) => a.type == AttachmentType.image);
    final hasAudio = n.attachments.any((a) => a.type == AttachmentType.audio);
    final hasVideo = n.attachments.any((a) => a.type == AttachmentType.video);
    final hasText = n.title.isNotEmpty || n.content.isNotEmpty;

    final tags = n.tags.isNotEmpty
        ? n.tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty)
        : <String>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (n.seriesId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                child: Text('Series: ${n.seriesId}',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            Text(n.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (n.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(n.subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            if (n.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(n.content,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 4,
                  children:
                      tags.map((t) => Chip(label: Text(t))).toList(growable: false),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${n.createdAt.toLocal()}'.substring(0, 16),
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (hasText) const Icon(Icons.text_snippet, size: 16),
                  if (hasAudio) const Icon(Icons.mic, size: 16),
                  if (hasImage) const Icon(Icons.image, size: 16),
                  if (hasVideo) const Icon(Icons.videocam, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTracker(BuildContext context, Tracker t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(t.type.name,
                style: Theme.of(context).textTheme.bodySmall),
            if (t.progress != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: LinearProgressIndicator(value: t.progress),
              ),
            if (t.start != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Start: ${t.start!.toLocal()}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProject(BuildContext context, Project p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(p.title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
