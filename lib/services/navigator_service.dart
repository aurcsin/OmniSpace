import 'package:flutter/material.dart';
import 'package:omnispace/services/tracker_service.dart';

/// A simple global navigator key so services can push routes.
class NavigatorService {
  NavigatorService._();
  static final NavigatorService instance = NavigatorService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Opens the Forge editor for a given Tracker ID.
  ///
  /// The [trackerId] is looked up in [TrackerService] so that the
  /// editor receives the full [Tracker] object. If no matching tracker
  /// is found, nothing happens.
  Future<void> openTrackerEditor(String trackerId) async {
    final trackers =
        TrackerService.instance.all.where((t) => t.id == trackerId).toList();
    if (trackers.isNotEmpty) {
      navigatorKey.currentState?.pushNamed('/forge', arguments: trackers.first);
    }
  }
}
