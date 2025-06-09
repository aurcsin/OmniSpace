// lib/services/stats_service.dart

import 'dart:convert';

import 'package:flutter/foundation.dart'; // <-- for debugPrint
import 'package:http/http.dart' as http;

import '../models/omni_note.dart';

class StatsService {
  StatsService._();
  static final instance = StatsService._();

  static const String _baseUrl = 'https://api.yourapp.com/stats';

  Future<void> updateStatsForEntry(OmniNote note, {http.Client? client}) async {
    client ??= http.Client();
    final url = Uri.parse('$_baseUrl/update');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update stats: ${response.body}');
    }
  }
}
