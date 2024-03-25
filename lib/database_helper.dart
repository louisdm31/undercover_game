import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.private();
  static Database? _database;
  static const String _dbName = 'game_results.db';

  DatabaseHelper.private();

  factory DatabaseHelper() => _instance;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
    }
    databaseFactory = databaseFactoryFfi;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE result (
        id INTEGER PRIMARY KEY,
        game INTEGER,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        won INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY,
        civilianWord TEXT NOT NULL,
        undercoverWord TEXT NOT NULL,
        whiteGuess TEXT NOT NULL
      )
    ''');
  }

  Future<void> _insertResults(Database db, String civilianWord, String undercoverWord, String whiteGuess, List<String> names, List<String> roles, List<bool> winning) async {
    int id = await db.insert(
      'games',
      {
        'civilianWord': civilianWord,
        'undercoverWord': undercoverWord,
        'whiteGuess': whiteGuess,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (int i = 0; i < names.length; i++) {
      await db.insert(
        'result',
        {
          'game': id,
          'name': names[i],
          'role': roles[i],
          'won': winning[i] ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> insertResults(String civilianWord, String undercoverWord, String whiteGuess, List<String> names, List<String> roles, List<bool> winning) async {
    Database? db = await database;
    await _insertResults(db!, civilianWord, undercoverWord, whiteGuess, names, roles, winning);
  }

  Future<String> _queryExecutor(Database db, String query) async {
    var result;
    try {
      result = await db.rawQuery(query);
    } catch (e) {
      return 'Error executing query: $e';
    }
    if (result.isNotEmpty) {
      return json.encode(result);
    } else {
      return 'Empty Result';
    }
  }

  Future<String> executeQuery(String query) async {
    Database? db = await database;
    return _queryExecutor(db!, query);
  }
}

