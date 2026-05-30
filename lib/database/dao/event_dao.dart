import 'package:sqflite/sqflite.dart';
import '../../database/app_database.dart';
import '../../models/event.dart';

class EventDao {
  final AppDatabase _dbProvider = AppDatabase.instance;
  static const String tableName = 'events';

  Future<int> insert(Event event) async {
    final Database db = await _dbProvider.database;
    return await db.insert(
      tableName,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<int> update(Event event) async {
    final Database db = await _dbProvider.database;
    return await db.update(
      tableName,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id]
    );
  }

  Future<int> delete(int id) async {
    final Database db = await _dbProvider.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<List<Event>> findAll() async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((m) => Event.fromMap(m)).toList();
  }
  
  Future<Event?> findById(int id) async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Event.fromMap(maps.first);
  }
}
