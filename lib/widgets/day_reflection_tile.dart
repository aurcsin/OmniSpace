// lib/widgets/day_reflection_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/day_reflection.dart';

/// A simple tile showing a single DayReflection.
class DayReflectionTile extends StatelessWidget {
  final DayReflection reflection;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const DayReflectionTile({
    super.key,
    required this.reflection,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(reflection.dateKey);
    final formattedDate = DateFormat.yMMMMd().format(date);

    return ListTile(
      title: Text(formattedDate),
      subtitle: Text(
        reflection.summary != null && reflection.summary!.isNotEmpty
            ? reflection.summary!
            : '(No reflection)',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
