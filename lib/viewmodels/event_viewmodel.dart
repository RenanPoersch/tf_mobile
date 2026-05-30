import 'package:flutter/foundation.dart';
import '../database/dao/event_dao.dart';
import '../models/event.dart';

class EventViewModel extends ChangeNotifier {
  final EventDao _eventDao = EventDao();

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];

  List<Event> get events => List.unmodifiable(_filteredEvents);

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> loadEvents() async {
    _allEvents = await _eventDao.findAll();
    _applyFilter();
    notifyListeners();
  }

  Future<int> addEvent(Event event) async {
    final id = await _eventDao.insert(event);
    await loadEvents();
    return id;
  }

  Future<int> updateEvent(Event event) async {
    final rows = await _eventDao.update(event);
    await loadEvents();
    return rows;
  }

  Future<int> deleteEvent(int id) async {
    final rows = await _eventDao.delete(id);
    await loadEvents();
    return rows;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();

    if (q.isEmpty) {
      _filteredEvents = List.from(_allEvents);
    } else {
      _filteredEvents = _allEvents.where((event) {
        return event.name.toLowerCase().contains(q) ||
            event.description.toLowerCase().contains(q);
      }).toList();
    }
  }
}