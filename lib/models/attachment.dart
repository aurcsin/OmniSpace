// lib/models/attachment.dart

import 'package:hive/hive.dart';

part 'attachment.g.dart';

@HiveType(typeId: 2)
enum AttachmentType {
  @HiveField(0)
  image,

  @HiveField(1)
  audio,

  @HiveField(2)
  video,
}

@HiveType(typeId: 3)
class Attachment extends HiveObject {
  @HiveField(0)
  AttachmentType type;

  /// Full local path to the file
  @HiveField(1)
  String localPath;

  /// When this attachment was created
  @HiveField(2)
  DateTime createdAt;

  /// For audio/video: optional transcription or notes
  @HiveField(3)
  String? transcription;

  /// For video: optional thumbnail path (can be generated later)
  @HiveField(4)
  String? thumbnailPath;

  Attachment({
    required this.type,
    required this.localPath,
    DateTime? createdAt,
    this.transcription,
    this.thumbnailPath,
  }) : this.createdAt = createdAt ?? DateTime.now();
}
