// lib/services/stats_service.dart

import 'package:flutter/foundation.dart'; // for debugPrint
import '../models/omni_note.dart';

class StatsService {
  StatsService._();
  static final instance = StatsService._();

  Future<void> updateStatsForEntry(OmniNote note) async {
    // TODO: Replace with real Stats/Emblems logic
    debugPrint(
      '[StatsService] 📊 Updating stats for note key=${note.key}, '
      'zone=${note.zone}, recommendedTag=${note.recommendedTag}, '
      'tags=${note.tags}',
    );
  }
}
