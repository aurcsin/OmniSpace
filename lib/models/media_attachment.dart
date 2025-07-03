import 'package:hive/hive.dart';
import 'attachment.dart';

part 'media_attachment.g.dart';

@HiveType(typeId: 5)
class MediaAttachment extends HiveObject {
  @HiveField(0)
  String path;

  @HiveField(1)
  AttachmentType type;

  @HiveField(2)
  DateTime addedAt;

  MediaAttachment({
    required this.path,
    required this.type,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}
