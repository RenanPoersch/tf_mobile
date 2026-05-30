import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get  database async {
    if(_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'events_manager.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await _seedIfEmpty(db);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        active INTEGER NOT NULL
      )
      '''
    );

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        eventType INTEGER NOT NULL,
        image TEXT
      )
    ''');

     await db.execute('''
      CREATE TABLE registrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        eventId INTEGER NOT NULL,
        isConfirmed INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (eventId) REFERENCES events (id)
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedIfEmpty(Database db) async {
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM users');
    final count = result.first['count'] as int? ?? 0;

    if (count == 0) {
      await _seedDatabase(db);
    }
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed data: usuários, eventos e inscrições iniciais
    final user1Id = await db.insert('users', {
      'name': 'Ana Silva',
      'email': 'ana.silva@example.com',
      'active': 1,
    });

    final user2Id = await db.insert('users', {
      'name': 'Bruno Costa',
      'email': 'bruno.costa@example.com',
      'active': 1,
    });

    final event1Id = await db.insert('events', {
      'name': 'Flutter Workshop',
      'description': 'Oficina prática de Flutter',
      'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'eventType': 1,
      'image': null,
    });

    final event2Id = await db.insert('events', {
      'name': 'Encontro de Devs',
      'description': 'Palestras e networking',
      'date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'eventType': 2,
      'image': null,
    });

    await db.insert('registrations', {
      'userId': user1Id,
      'eventId': event1Id,
      'isConfirmed': 1,
    });

    await db.insert('registrations', {
      'userId': user2Id,
      'eventId': event2Id,
      'isConfirmed': 0,
    });
  }
}