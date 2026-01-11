import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/auth_user.dart';
import '../models/sync_models.dart';

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

    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
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
    
    await _createHardwareTables(db);
    await _createPrebuiltTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createHardwareTables(db);
    }
    if (oldVersion < 3) {
      await _createPrebuiltTable(db);
    }
  }

  Future<void> _createHardwareTables(Database db) async {
    const tableSchema = 'id INTEGER PRIMARY KEY, name TEXT, price REAL';
    await db.execute('CREATE TABLE cpus ($tableSchema)');
    await db.execute('CREATE TABLE gpus ($tableSchema)');
    await db.execute('CREATE TABLE memory ($tableSchema)');
    await db.execute('CREATE TABLE storage ($tableSchema)');
    await db.execute('CREATE TABLE motherboards ($tableSchema)');
    await db.execute('CREATE TABLE power_supplies ($tableSchema)');
    await db.execute('CREATE TABLE cases ($tableSchema)');
  }

  Future<void> _createPrebuiltTable(Database db) async {
    await db.execute('''
      CREATE TABLE prebuilts (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        price REAL, 
        rating REAL, 
        imageUrl TEXT
      )
    ''');
  }

  Future<void> processSyncBatch(String tableName, List<HardwareItem> items) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var item in items) {
      if (item.isDeleted) {
        batch.delete(tableName, where: 'id = ?', whereArgs: [item.id]);
      } else {
        batch.insert(tableName, item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> processPrebuiltBatch(List<PrebuiltItem> items) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var item in items) {
      if (item.isDeleted) {
        batch.delete('prebuilts', where: 'id = ?', whereArgs: [item.id]);
      } else {
        batch.insert('prebuilts', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    await batch.commit(noResult: true);
  }

  Future<List<PrebuiltItem>> getTopRatedPrebuilts() async {
    final db = await instance.database;
    final result = await db.query(
      'prebuilts', 
      orderBy: 'rating DESC', 
      limit: 5
    );
    return result.map((json) => PrebuiltItem.fromJson(json)).toList();
  }

  Future<List<HardwareItem>> getItems(String tableName) async {
    final db = await instance.database;
    final result = await db.query(tableName, orderBy: 'name ASC');
    return result.map((json) => HardwareItem(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isDeleted: false
    )).toList();
  }
  
  Future<void> saveUser(AuthUser user) async {
    final db = await instance.database;
    await db.delete('user');
    await db.insert('user', user.toMap());
  }

  Future<AuthUser?> getUser() async {
    final db = await instance.database;
    final maps = await db.query('user');
    if (maps.isNotEmpty) return AuthUser.fromJson(maps.first);
    return null;
  }

  Future<void> deleteUser() async {
    final db = await instance.database;
    await db.delete('user');
  }
}