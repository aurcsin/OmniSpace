// File: lib/models/attachment.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'attachment.g.dart';

/// Types of attachments for notes.
@HiveType(typeId: 0)
enum AttachmentType {
  @HiveField(0)
  image,
  @HiveField(1)
  audio,
  @HiveField(2)
  video,
}

/// A note attachment, stored locally and/or synced.
@HiveType(typeId: 2)
class Attachment extends HiveObject {
  @HiveField(0)
  AttachmentType type;

  @HiveField(1)
  String localPath;

  Attachment({
    required this.type,
    required this.localPath,
  });

  /// Convert to JSON for sync or serialization.
  Map<String, dynamic> toJson() => {
        'type': describeEnum(type),
        'localPath': localPath,
      };

  /// Create from JSON map.
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      type: AttachmentType.values.firstWhere(
        (t) => describeEnum(t) == json['type'] as String,
      ),
      localPath: json['localPath'] as String,
    );
  }
}
