import 'package:flutter_test/flutter_test.dart';
import 'package:omnispace/services/goal_service.dart';
import 'package:omnispace/models/goal.dart';
import 'package:omnispace/services/event_service.dart';
import 'package:omnispace/models/event.dart';

void main() {
  group('GoalService.reorder', () {
    test('throws ArgumentError on invalid indices', () {
      expect(() => GoalService.instance.reorder(0, 0), throwsArgumentError);

      GoalService.instance.add(Goal(id: 'g1'));
      expect(() => GoalService.instance.reorder(-1, 0), throwsArgumentError);
      expect(() => GoalService.instance.reorder(0, 2), throwsArgumentError);
    });

    test('valid reorder moves item', () {
      GoalService.instance.add(Goal(id: 'g2'));
      GoalService.instance.reorder(0, 2);
      expect(GoalService.instance.goals.first.id, 'g2');
    });
  });

  group('EventService.reorder', () {
    test('throws ArgumentError on invalid indices', () {
      expect(() => EventService.instance.reorder(0, 0), throwsArgumentError);

      EventService.instance.add(Event(id: 'e1', start: DateTime.now()));
      expect(() => EventService.instance.reorder(-1, 0), throwsArgumentError);
      expect(() => EventService.instance.reorder(0, 2), throwsArgumentError);
    });

    test('valid reorder moves item', () {
      EventService.instance.add(Event(id: 'e2', start: DateTime.now()));
      EventService.instance.reorder(0, 2);
      expect(EventService.instance.events.first.id, 'e2');
    });
  });
}
