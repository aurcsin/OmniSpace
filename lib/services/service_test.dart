import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/services/garden_service.dart';
import 'package:omnispace/services/spirit_buddy_service.dart';
import 'package:omnispace/services/stats_service.dart';

void main() {
  final note = OmniNote(id: '1');

  test('GardenService.addFlowerFromEntry posts note data', () async {
    var called = false;
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://api.yourapp.com/garden/flowers');
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      expect(data['id'], note.id);
      called = true;
      return http.Response('{}', 201);
    });

    await GardenService.instance.addFlowerFromEntry(note, client: client);
    expect(called, isTrue);
  });

  test('SpiritBuddyService.reflectOnEntry posts note data', () async {
    var called = false;
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://api.yourapp.com/spirit/reflect');
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      expect(data['id'], note.id);
      called = true;
      return http.Response('{}', 201);
    });

    await SpiritBuddyService.instance.reflectOnEntry(note, client: client);
    expect(called, isTrue);
  });

  test('StatsService.updateStatsForEntry posts note data', () async {
    var called = false;
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://api.yourapp.com/stats/update');
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      expect(data['id'], note.id);
      called = true;
      return http.Response('{}', 201);
    });

    await StatsService.instance.updateStatsForEntry(note, client: client);
    expect(called, isTrue);
  });
}
