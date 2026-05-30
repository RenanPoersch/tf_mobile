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
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed data: usuários, eventos e inscrições iniciais.
    // Cada bloco só insere o item se ele ainda não existir.
    final user1Id = await _ensureUser(
      db,
      name: 'Ana Silva',
      email: 'ana.silva@example.com',
    );

    final user2Id = await _ensureUser(
      db,
      name: 'Bruno Costa',
      email: 'bruno.costa@example.com',
    );

    final event1Id = await _ensureEvent(
      db,
      name: 'Flutter Workshop',
      description: 'Oficina prática de Flutter',
      date: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      eventType: 1,
      image: '',
    );

    final event2Id = await _ensureEvent(
      db,
      name: 'Encontro de Devs',
      description: 'Palestras e networking',
      date: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      eventType: 2,
      image: '',
    );

    await _ensureRegistration(
      db,
      userId: user1Id,
      eventId: event1Id,
      isConfirmed: 1,
    );

    await _ensureRegistration(
      db,
      userId: user2Id,
      eventId: event2Id,
      isConfirmed: 0,
    );
  }

  Future<int> _ensureUser(
    Database db, {
    required String name,
    required String email,
  }) async {
    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return db.insert('users', {
      'name': name,
      'email': email,
      'active': 1,
    });
  }

  Future<int> _ensureEvent(
    Database db, {
    required String name,
    required String description,
    required String date,
    required int eventType,
    required String image,
  }) async {
    final existing = await db.query(
      'events',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return db.insert('events', {
      'name': name,
      'description': description,
      'date': date,
      'eventType': eventType,
      'image': image,
    });
  }

  Future<void> _ensureRegistration(
    Database db, {
    required int userId,
    required int eventId,
    required int isConfirmed,
  }) async {
    final existing = await db.query(
      'registrations',
      columns: ['id'],
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return;
    }

    await db.insert('registrations', {
      'userId': userId,
      'eventId': eventId,
      'isConfirmed': isConfirmed,
    });
  }
}