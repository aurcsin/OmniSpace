// lib/services/ai_service.dart

import 'dart:async';

class AIService {
  AIService._();
  static final instance = AIService._();

  /// Generates a dummy “recommended tag” from the content.
  Future<String?> generateRecommendedTag(String content) async {
    await Future.delayed(Duration(milliseconds: 300));
    final words = content
        .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '')
        .split(' ')
        .where((w) => w.length > 3)
        .toList();
    if (words.isEmpty) return null;
    words.shuffle();
    return '#${words.first.toLowerCase()}';
  }
}
