import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/dao/user_dao.dart';
import '../models/user.dart';

class UserViewModel extends ChangeNotifier {
  final UserDao _userDao = UserDao();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  List<User> get users => List.unmodifiable(_filteredUsers);
  
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> loadUsers() async {
    _allUsers = await _userDao.findAll();
    _applyFilter();
    notifyListeners();
  }

  Future<int> addUser(User user) async {
    final id = await _userDao.insert(user);
    await loadUsers();
    return id;
  }

  Future<int> updateUser(User user) async {
    final rows = await _userDao.update(user);
    await loadUsers();
    return rows;
  }

  Future<int> deleteUser(User user) async {
    final rows = await _userDao.delete(user);
    await loadUsers();
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
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((u) {
        return u.name.toLowerCase().contains(q) || 
        u.email.toLowerCase().contains(q);
      }).toList();
    }
  }
}
