import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../models/User.dart';

class DatabaseHelper {
  static final _databaseName = "my_database.db";
  static final _databaseVersion = 1;

  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE user(id INTEGER PRIMARY KEY, role INTEGER, name TEXT, email TEXT, address TEXT, phone TEXT, token TEXT)');
  }

  Future<void> insertUser(User user) async {
    final db = await database;

    await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    
    await db.rawUpdate('UPDATE user SET role = ? WHERE id = ?', [user.role, user.id]);

    /*await db.update(
      'user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );*/
  }

  Future<void> deleteUser(int id) async {
    final db = await database;

    await db.delete(
      'user',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  deleteAll() async {
    Database db = await instance.database;
    return await db.rawDelete("Delete from user");
  }

  Future<List<Map<String, dynamic>>> users() async {
    Database db = await instance.database;
    return await db.query('user');
  }
}
