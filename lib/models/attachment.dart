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

  @HiveField(1)
  String localPath;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  String? transcription;

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
