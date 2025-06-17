import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/event.dart';

class EventService extends ChangeNotifier {
  EventService._();
  static final instance = EventService._();

  static const String _boxName = 'events';
  late Box<Event> _box;

  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(EventAdapter().typeId)) {
      Hive.registerAdapter(EventAdapter());
    }
    _box = await Hive.openBox<Event>(_boxName);
    _events
      ..clear()
      ..addAll(_box.values);
    notifyListeners();
  }

  Future<void> save(Event event) async {
    await _box.put(event.id, event);
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      _events.add(event);
    } else {
      _events[index] = event;
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> add(Event event) => save(event);

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) {
      throw ArgumentError('oldIndex and newIndex must differ');
    }
    if (oldIndex < 0 || oldIndex >= _events.length) {
      throw ArgumentError('oldIndex out of range');
    }
    if (newIndex < 0 || newIndex > _events.length) {
      throw ArgumentError('newIndex out of range');
    }

    if (oldIndex < newIndex) newIndex -= 1;
    final item = _events.removeAt(oldIndex);
    _events.insert(newIndex, item);
    notifyListeners();
  }
}
