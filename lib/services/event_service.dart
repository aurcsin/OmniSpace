import 'package:flutter/foundation.dart';
import '../models/event.dart';

class EventService extends ChangeNotifier {
  EventService._();
  static final instance = EventService._();

  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  void add(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _events.removeAt(oldIndex);
    _events.insert(newIndex, item);
    notifyListeners();
  }
}