// ignore_for_file: depend_on_referenced_packages

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initializeDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> initializeDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'spendwise.db');
    Database mydb = await openDatabase(path, onCreate: _onCreate, version: 4, onUpgrade: _onUpgrade);
    return mydb;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Perform database upgrade operations here
      if (oldVersion == 2) {
        // Example: Drop a column from a table
        await db.execute('ALTER TABLE debtTb DROP COLUMN totaldebt');
        await db.execute('ALTER TABLE creditTb DROP COLUMN totalcredit');
      }
    }
  }

  void _onCreate(Database db, int version) async {
    // create login table
    await db.execute('''
      CREATE TABLE loginTb (
        username TEXT NOT NULL,
        password INTEGER NOT NULL
      )
    ''');

    // create debtTb table
    await db.execute('''
      CREATE TABLE debtTb (
        descrption TEXT NOT NULL,
        amount INTEGER NOT NULL,
        totalcredit INTEGER NULL
      )
    ''');

    // create creditTb table
    await db.execute('''
      CREATE TABLE creditTb (
        descrption TEXT NOT NULL,
        amount INTEGER NOT NULL,
        totalcredit INTEGER NULL
      )
    ''');

    // create walletTb table
    await db.execute('''
      CREATE TABLE walletTb (
        totalwallet INTEGER NOT NULL
      )
    ''');

    print("create database and table...");
  }

  Future<List<Map<String, dynamic>>> selectData(String query) async {
    Database? mydb = await db;
    List<Map<String, dynamic>> result = await mydb!.rawQuery(query);
    return result;
  }

  Future<List<Map<String, dynamic>>> selectAccount(String sql) async {
    Database? mydb = await db;
    List<Map<String, dynamic>> response = await mydb!.rawQuery(sql);
    return response;
  }

  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  // Future<void> deleteDatabase() async {
  //   String databasePath = await getDatabasesPath();
  //   String path = join(databasePath, 'spendwise.db');
  //   await deleteDatabase(path);
  //   print("delete database done");
  // }
}