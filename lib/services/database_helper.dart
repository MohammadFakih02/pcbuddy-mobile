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
    return await openDatabase(path, version: 6, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      token TEXT NOT NULL,
      role TEXT NOT NULL,
      profilePicture TEXT,
      bio TEXT
    )
    ''');
    
    await _createHardwareTables(db);
    
    await db.execute('''
      CREATE TABLE prebuilts (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        price REAL, 
        rating REAL, 
        imageUrl TEXT,
        cpuId INTEGER,
        gpuId INTEGER,
        memoryId INTEGER,
        storageId INTEGER,
        motherboardId INTEGER,
        psuId INTEGER,
        caseId INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createHardwareTables(db);
    }
    
    if (oldVersion < 3) {
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
    if (oldVersion < 4) {
      await _addImagesToHardware(db);
    }

    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE user ADD COLUMN bio TEXT');
      } catch (e) {
        // Ignore if exists
      }
    }
    if (oldVersion < 6) {
      try {
        await db.execute('DROP TABLE IF EXISTS prebuilts');
        await db.execute('''
          CREATE TABLE prebuilts (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            price REAL, 
            rating REAL, 
            imageUrl TEXT,
            cpuId INTEGER,
            gpuId INTEGER,
            memoryId INTEGER,
            storageId INTEGER,
            motherboardId INTEGER,
            psuId INTEGER,
            caseId INTEGER
          )
        ''');
      } catch (e) {
        print("Error upgrading prebuilts: $e");
      }
    }
  }

  Future<void> _createHardwareTables(Database db) async {
    const tableSchema = 'id INTEGER PRIMARY KEY, name TEXT, price REAL, imageUrl TEXT';
    await db.execute('CREATE TABLE cpus ($tableSchema)');
    await db.execute('CREATE TABLE gpus ($tableSchema)');
    await db.execute('CREATE TABLE memory ($tableSchema)');
    await db.execute('CREATE TABLE storage ($tableSchema)');
    await db.execute('CREATE TABLE motherboards ($tableSchema)');
    await db.execute('CREATE TABLE power_supplies ($tableSchema)');
    await db.execute('CREATE TABLE cases ($tableSchema)');
  }

  Future<void> _addImagesToHardware(Database db) async {
    final tables = ['cpus', 'gpus', 'memory', 'storage', 'motherboards', 'power_supplies', 'cases'];
    for (var table in tables) {
      try {
        await db.execute('ALTER TABLE $table ADD COLUMN imageUrl TEXT');
      } catch (e) {
        // Ignore if exists
      }
    }
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

  Future<List<HardwareItem>> getItems(
    String tableName, {
    int limit = 20, 
    int offset = 0, 
    String query = ''
  }) async {
    final db = await instance.database;
    
    String? whereClause;
    List<dynamic>? whereArgs;

    if (query.isNotEmpty) {
      whereClause = 'name LIKE ?';
      whereArgs = ['%$query%'];
    }

    final result = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'price DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((json) => HardwareItem.fromJson(json)).toList();
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

  Future<Map<String, HardwareItem?>> getPrebuiltParts(PrebuiltItem pc) async {
    final db = await instance.database;
    
    Future<HardwareItem?> fetch(String table, int? id) async {
      if (id == null) return null;
      final maps = await db.query(table, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) return HardwareItem.fromJson(maps.first);
      return null;
    }

    return {
      "CPU": await fetch('cpus', pc.cpuId),
      "GPU": await fetch('gpus', pc.gpuId),
      "Motherboard": await fetch('motherboards', pc.motherboardId),
      "RAM": await fetch('memory', pc.memoryId),
      "Storage": await fetch('storage', pc.storageId),
      "PSU": await fetch('power_supplies', pc.psuId),
      "Case": await fetch('cases', pc.caseId),
    };
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