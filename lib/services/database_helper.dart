import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/auth_user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pcbuddy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      token TEXT NOT NULL,
      role TEXT NOT NULL,
      profilePicture TEXT
    )
    ''');
  }

  Future<void> saveUser(AuthUser user) async {
    final db = await instance.database;
    // We only keep one user logged in at a time, so clear table first
    await db.delete('user'); 
    await db.insert('user', user.toMap());
  }

  Future<AuthUser?> getUser() async {
    final db = await instance.database;
    final maps = await db.query('user');

    if (maps.isNotEmpty) {
      return AuthUser.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<void> deleteUser() async {
    final db = await instance.database;
    await db.delete('user');
  }
}