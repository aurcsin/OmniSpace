// lib/services/garden_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/omni_note.dart';

class GardenService {
  GardenService._();
  static final instance = GardenService._();

  static const String _baseUrl = 'https://api.yourapp.com/garden';

  Future<void> addFlowerFromEntry(OmniNote note, {http.Client? client}) async {
    client ??= http.Client();
    final url = Uri.parse('$_baseUrl/flowers');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add flower: ${response.body}');
    }
  }
}
