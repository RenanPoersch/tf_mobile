import 'package:flutter/foundation.dart';
import '../database/dao/registration_dao.dart';
import '../models/registration.dart';

class RegistrationViewModel extends ChangeNotifier {
  final RegistrationDao _registrationDao = RegistrationDao();

  List<Registration> _allRegistrations = [];
  List<Registration> _filteredRegistrations = [];

  List<Registration> get registrations =>
      List.unmodifiable(_filteredRegistrations);

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> loadRegistrations() async {
    _allRegistrations = await _registrationDao.findAll();
    _applyFilter();
    notifyListeners();
  }

  Future<int> addRegistration(Registration registration) async {
    final id = await _registrationDao.insert(registration);
    await loadRegistrations();
    return id;
  }

  Future<int> updateRegistration(Registration registration) async {
    final rows = await _registrationDao.update(registration);
    await loadRegistrations();
    return rows;
  }

  Future<int> deleteRegistration(int id) async {
    final rows = await _registrationDao.delete(id);
    await loadRegistrations();
    return rows;
  }

  Future<int> updateConfirmation(int id, bool isConfirmed) async {
    final rows = await _registrationDao.updateConfirmation(id, isConfirmed);
    await loadRegistrations();
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
      _filteredRegistrations = List.from(_allRegistrations);
    } else {
      _filteredRegistrations = _allRegistrations.where((registration) {
        return registration.userId.toString().contains(q) ||
            registration.eventId.toString().contains(q) ||
            registration.isConfirmed.toString().toLowerCase().contains(q);
      }).toList();
    }
  }
}