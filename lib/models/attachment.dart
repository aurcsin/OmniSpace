// lib/models/attachment.dart

import 'package:hive/hive.dart';

part 'attachment.g.dart';

@HiveType(typeId: 1)
enum AttachmentType {
  @HiveField(0)
  image,
  @HiveField(1)
  audio,
  @HiveField(2)
  video,
}

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
}
