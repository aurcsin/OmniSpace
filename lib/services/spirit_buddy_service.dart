// lib/services/spirit_buddy_service.dart

import 'package:flutter/foundation.dart'; // for debugPrint
import '../models/omni_note.dart';

class SpiritBuddyService {
  SpiritBuddyService._();
  static final instance = SpiritBuddyService._();

  void reflectOnEntry(OmniNote note) {
    // TODO: Replace with real AI/Spirit-buddy reflection logic
    debugPrint(
      '[SpiritBuddyService] 💬 Reflecting on note key=${note.key}, '
      'zone=${note.zone}, recommendedTag=${note.recommendedTag}',
    );
  }
}
