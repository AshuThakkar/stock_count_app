import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:stock_count_app/classes/OfflineBatch.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;
  static String dbPath = "StockCount_Loc.db";

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var databasesPath = "";

    String dbath = await getDatabasesPath();
    databasesPath = p.join(dbath, dbPath);

    var cardDatabase =
        await openDatabase(databasesPath, version: 2, onCreate: _createDb);
    return cardDatabase;
  }

//-----------------------Android----------------------------

  // Future<String> getPersistentDbPath() async {
  //   return await createPersistentDbDirecotry();
  // }

  // Future<String> createPersistentDbDirecotry() async {
  //   var externalDirectoryPath = await ExtStorage.getExternalStorageDirectory();
  //   var persistentDirectory = "$externalDirectoryPath/db_persistent";
  //   var directory = await createDirectory(persistentDirectory);
  //   listFiles(directory);
  //   return "$persistentDirectory/" + dbPath;
  // }

  listFiles(Directory directory) {
    if (kDebugMode) {
      print("${directory.path} files:");
    }
    directory.list().forEach((file) {
      if (kDebugMode) {
        print(file.path);
      }
      if (kDebugMode) {
        print(file.statSync().size);
      }
    });
  }

  Future<Directory> createDirectory(String path) async {
    return await (Directory(path).create());
  }

//-----------------------------------------------------------------

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE BATCH(BATCH_ID INTEGER PRIMARY KEY AUTOINCREMENT, BATCHNAME TEXT)');
    await db.execute(
        'CREATE TABLE BATCHITEM(BITEM_ID INTEGER PRIMARY KEY AUTOINCREMENT, BATCH_ID INTEGER,UPC TEXT,STOCK TEXT)');
  }

  //-----> Offline Batch

  Future<List<Map<String, dynamic>>> getBatchMapList() async {
    Database db = await database;
    var result = await db.query("BATCH");
    return result;
  }

  Future<List<OfflineBatch>> getBatchList() async {
    var batchlist = await getBatchMapList();
    // int count = batchlist.length;
    List<Map<String, dynamic>> batchItems;
    OfflineBatch objBatch;

    List<OfflineBatch> lstBatches = [];
    for (var i = 0; i < batchlist.length; i++) {
      objBatch = OfflineBatch.fromMapObject(batchlist[i]);
      batchItems = await getBatchItemList(objBatch.batchID!);
      for (var j = 0; j < batchItems.length; j++) {
        objBatch.batchItems.add(OfflineBatchItem.fromMapObject(batchItems[j]));
      }
      lstBatches.add(objBatch);
    }
    return lstBatches;
  }

  Future<List<Map<String, dynamic>>> getBatchItemList(int batchID) async {
    Database db = await database;
    var result = await db
        .query("BATCHITEM", where: "BATCH_ID = ?", whereArgs: [batchID]);
    return result;
  }

  Future<int> deleteBatch(int id) async {
    Database db = await database;
    var result =
        await db.delete("BATCHITEM", where: 'BATCH_ID = ?', whereArgs: [id]);
    result = await db.delete("BATCH", where: 'BATCH_ID = ?', whereArgs: [id]);
    return result;
  }

  Future<int> insertUpdateBatch(OfflineBatch batch) async {
    Database db = await database;
    int dbID = 0;
    if (batch.batchID == null || batch.batchID == 0) {
      dbID = await db.insert("BATCH", batch.toMap());
    } else {
      await db.update("BATCH", batch.toMap(),
          where: 'BATCH_ID = ?', whereArgs: [batch.batchID]);
      await db.delete("BATCHITEM",
          where: 'BATCH_ID = ?', whereArgs: [batch.batchID]);
      dbID = batch.batchID!;
    }

    if (dbID != 0 && batch.batchItems.isNotEmpty) {
      for (int y = 0; y < batch.batchItems.length; y++) {
        batch.batchItems[y].batchID = dbID;
        await db.insert("BATCHITEM", batch.batchItems[y].toMap());
      }
    }
    return dbID;
  }
}
