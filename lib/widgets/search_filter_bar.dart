// File: lib/widgets/search_filter_bar.dart

import 'package:flutter/material.dart';
import '../services/search_filter_service.dart';

/// A universal search and date-range filter bar
class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({Key? key}) : super(key: key);

  @override
  _SearchFilterBarState createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _svc = SearchFilterService.instance;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _svc.query);
    _svc.addListener(_onSvc);
  }

  void _onSvc() {
    if (_ctrl.text != _svc.query) {
      _ctrl.text = _svc.query;
      _ctrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _ctrl.text.length),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _svc.removeListener(_onSvc);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: _svc.updateQuery,
              ),
            ),
            ToggleButtons(
              isSelected:
                  ViewMode.values.map((m) => m == _svc.viewMode).toList(),
              onPressed: (i) => _svc.updateViewMode(ViewMode.values[i]),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Day')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Week')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Month')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Year')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
