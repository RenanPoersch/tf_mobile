import 'package:sqflite/sqflite.dart';
import '../../database/app_database.dart';
import '../../models/user.dart';

class UserDao {
  final AppDatabase _dbProvider = AppDatabase.instance;
  static const String tableName = 'users';

  Future<int> insert(User user) async {
    final Database db = await _dbProvider.database;
    return await db.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<int> update(User user) async {
    final Database db = await _dbProvider.database;
    return await db.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id]
    );
  }

  Future<int> delete(User user) async {
    final Database db = await _dbProvider.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [user.id]
    );
  }

  Future<List<User>> findAll() async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((m) => User.fromMap(m)).toList();
  }
  
  Future<User?> findById(int id) async {
    final Database db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }
}
