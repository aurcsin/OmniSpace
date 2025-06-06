// lib/services/garden_service.dart

import 'package:flutter/foundation.dart'; // for debugPrint
import '../models/omni_note.dart';

class GardenService {
  GardenService._();
  static final instance = GardenService._();

  Future<void> addFlowerFromEntry(OmniNote note) async {
    // TODO: Replace with real Garden logic
    debugPrint(
      '[GardenService] 🌸 Spawning flower for note key=${note.key}, '
      'zone=${note.zone}',
    );
  }
}
