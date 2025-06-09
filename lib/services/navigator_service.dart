import 'package:flutter/material.dart';

/// A simple global navigator key so services can push routes.
class NavigatorService {
  NavigatorService._();
  static final NavigatorService instance = NavigatorService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Opens the Forge editor for a given Tracker ID.
  Future<void> openTrackerEditor(String trackerId) async {
    navigatorKey.currentState
        ?.pushNamed('/forge', arguments: trackerId);
  }
}
