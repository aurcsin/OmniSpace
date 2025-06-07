import 'package:hive/hive.dart';

part 'attachment.g.dart';

@HiveType(typeId: 1)
class Attachment extends HiveObject {
  @HiveField(0)
  String localPath;

  @HiveField(1)
  AttachmentType type;

  Attachment({required this.localPath, required this.type});
}

@HiveType(typeId: 2)
enum AttachmentType {
  @HiveField(0)
  image,
  @HiveField(1)
  audio,
  @HiveField(2)
  video,
}
