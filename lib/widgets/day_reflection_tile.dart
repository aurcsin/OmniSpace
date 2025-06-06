import 'package:flutter/material.dart';
import 'package:omnispace/models/day_reflection.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(
          'Reflection for ${reflection.dateKey}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(reflection.summary.isNotEmpty
            ? reflection.summary
            : 'No reflection added.'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
