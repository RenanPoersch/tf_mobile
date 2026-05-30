import 'package:sqflite/sqflite.dart';
import '../../database/app_database.dart';
import '../../models/registration.dart';

class RegistrationDao {
  final AppDatabase _dbProvider = AppDatabase.instance;
  static const String tableName = 'registrations';

  Future<int> insert(Registration registration) async {
    final Database db = await _dbProvider.database;
    return await db.insert(
      tableName,
      registration.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<int> update(Registration registration) async {
    final Database db = await _dbProvider.database;
    return await db.update(
      tableName,
      registration.toMap(),
      where: 'id = ?',
      whereArgs: [registration.id]
    );
  }

  Future<int> updateConfirmation(int id, bool isConfirmed) async {
    final Database db = await _dbProvider.database;
    return await db.update(
      tableName,
      {'isConfirmed': isConfirmed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(Registration registration) async {
    final Database db = await _dbProvider.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [registration.id]
    );
  }

  Future<List<Registration>> findAll() async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((m) => Registration.fromMap(m)).toList();
  }
  
  Future<Registration?> findById(int id) async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Registration.fromMap(maps.first);
  }

  Future<List<Registration>> findByUserId(int userId) async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((m) => Registration.fromMap(m)).toList();
  }

  Future<List<Registration>> findByEventId(int eventId) async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return maps.map((m) => Registration.fromMap(m)).toList();
  }
}
