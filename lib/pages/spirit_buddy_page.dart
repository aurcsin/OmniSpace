// lib/services/spirit_buddy_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/omni_note.dart';

class SpiritBuddyService {
  SpiritBuddyService._();
  static final instance = SpiritBuddyService._();

  static const String _baseUrl = 'https://api.yourapp.com/spirit';

  Future<void> reflectOnEntry(OmniNote note, {http.Client? client}) async {
    client ??= http.Client();
    final url = Uri.parse('$_baseUrl/reflect');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to reflect on entry: ${response.body}');
    }
  }
}
