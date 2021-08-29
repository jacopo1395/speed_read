import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._();
  static var _database;

  static const int DB_VERSION = 1;

  LocalStorageService._();

  factory LocalStorageService() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await _init();

    return _database;
  }

  Future<Database> _init() async {
    var directory = await getApplicationDocumentsDirectory();
    var dbPath = join(directory.path, 'database.db');
    var database = openDatabase(dbPath,
        version: DB_VERSION,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
    return database;
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    try {
      await createTable(db);
      debugPrint('Database was created!');
    } catch (e) {
      debugPrint('error during creation db: ${e.toString()}');
    }
  }

  Future createTable(Database db) async {
    await db.execute('''create TABLE book(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          path TEXT,
          text TEXT,
          length INTEGER,
          author TEXT,
          completion INTEGER
      );''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Run migration according database versions
    for (var i = oldVersion - 1; i <= newVersion - 1; i++) {
//      await db.execute(migrationScripts[i]);
    }
  }


  FutureOr<void> dropTable(Database db) async {
    await db.execute('drop table if exists book;');
  }
}
