import 'dart:io';
import 'package:hive/hive.dart';

/// Placeholder migration script for copying records between Hive boxes.
///
/// Usage:
///   dart run tool/hive_migrate.dart <oldPath> <newPath> <boxName>
///
/// Opens the box named [boxName] from [oldPath] and [newPath] and copies all
/// key/value pairs from the old box into the new one.
Future<void> main(List<String> args) async {
  final oldPath = args.isNotEmpty ? args[0] : 'old_hive';
  final newPath = args.length > 1 ? args[1] : 'hive';
  final boxName = args.length > 2 ? args[2] : 'omnispace';

  final oldBox = await Hive.openBox(boxName, path: oldPath);
  final newBox = await Hive.openBox(boxName, path: newPath);

  for (final key in oldBox.keys) {
    await newBox.put(key, oldBox.get(key));
  }

  await oldBox.close();
  await newBox.close();

  stdout.writeln('Migrated ${oldBox.length} entries from $oldPath to $newPath');
}
