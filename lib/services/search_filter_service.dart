// File: lib/services/search_filter_service.dart

import 'package:flutter/foundation.dart';

/// Provides global search query and date-range filtering
class SearchFilterService extends ChangeNotifier {
  SearchFilterService._();
  static final SearchFilterService instance = SearchFilterService._();

  String _query = '';
  DateTime _focusDate = DateTime.now();
  ViewMode _viewMode = ViewMode.day;

  String get query => _query;
  DateTime get focusDate => _focusDate;
  ViewMode get viewMode => _viewMode;

  void updateQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void updateFocusDate(DateTime date) {
    _focusDate = date;
    notifyListeners();
  }

  void updateViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }
}

/// Available date-range views
enum ViewMode { day, week, month, year }
