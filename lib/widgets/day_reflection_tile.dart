// lib/widgets/day_reflection_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/day_reflection.dart';

/// A simple tile showing a single DayReflection.
class DayReflectionTile extends StatelessWidget {
  final DayReflection reflection;
  final VoidCallback onEdit;

  const DayReflectionTile({
    Key? key,
    required this.reflection,
    required this.onEdit,
  }) : super(key: key);

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
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEdit,
      ),
    );
  }
}
