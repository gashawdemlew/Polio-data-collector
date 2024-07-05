import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "media.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE media (
        id INTEGER PRIMARY KEY,
        title TEXT,
        filePath TEXT,
        status INTEGER
      )
    ''');
  }

  Future<int> insertMedia(String title, String filePath) async {
    Database db = await database;
    return await db.insert('media', {
      'title': title,
      'filePath': filePath,
      'status': 0, // 0 indicates not uploaded
    });
  }

  Future<List<Map<String, dynamic>>> getPendingMedia() async {
    Database db = await database;
    return await db.query('media', where: 'status = ?', whereArgs: [0]);
  }

  Future<int> updateMediaStatus(int id) async {
    Database db = await database;
    return await db.update('media', {'status': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
