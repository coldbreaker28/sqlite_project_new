import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqlite_project/model/item.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute(
      '''
      create table items (
        id integer primary key autoincrement,
        name text,
        price integer,
        stok integer,
        kodeBarang text
        )
      '''
    );
  }
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'anas1.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }
  static Future<int> createItem(Item item) async {
    final db = await SQLHelper.db();
    int id = await db.insert('items', item.toMap(),
    conflictAlgorithm: sql.ConflictAlgorithm.replace
    );
    return id;
  }
  static Future<List<Item>> getItemList() async {
    final db = await SQLHelper.db();
    var mapList = await db.query('items', orderBy: 'name');
    int count = mapList.length;
    List<Item> itemList = [];
    for (int i=0; i < count; i++){
      itemList.add(Item.fromMap(mapList[i]));
    }
    return itemList;
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    var item = await db.query('items', where: 'id=?', whereArgs: [id], limit: 1);
    return item;
  }

  static Future<int> updateItem(Item item) async {
    final db = await SQLHelper.db();
    final result = await db.update('items', item.toMap(), where:  'id=?', whereArgs: [item.id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where:  'id=?',whereArgs: [id]);
    }catch (err){
      debugPrint("kesalahan menghapus item: $err");
    }
  }
}