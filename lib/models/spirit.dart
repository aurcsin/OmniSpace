import 'package:hive/hive.dart';
import 'package:omnispace/models/zone_theme.dart';

part 'spirit.g.dart';  // ← make sure this matches the generated file

@HiveType(typeId: 11)
class Spirit extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String mythos;
  @HiveField(3) final String purpose;
  @HiveField(4) final String useInApp;
  @HiveField(5) final ZoneTheme realm;
  @HiveField(6) final bool isPrimary;
  @HiveField(7) final bool isNPC;
  @HiveField(8) final bool isCollectible;
  @HiveField(9) final String archetype;
  @HiveField(10) final int xpValue;

  Spirit({
    required this.id,
    required this.name,
    required this.mythos,
    required this.purpose,
    required this.useInApp,
    required this.realm,
    this.isPrimary = false,
    this.isNPC = false,
    this.isCollectible = true,
    this.archetype = '',
    this.xpValue = 0,
  });
}
