import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  // **Membuka database**
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'tokline.db'),
      version: 3,
      onCreate: (Database database, int version) async {
        await database.execute("""
          CREATE TABLE items(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          nama_produk TEXT NOT NULL, 
          description TEXT DEFAULT '',
          img TEXT DEFAULT '',
          price REAL DEFAULT 0,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        """);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute("ALTER TABLE items ADD COLUMN img TEXT DEFAULT ''");
      }
      if (oldVersion < 3) {
        await db.execute("ALTER TABLE items ADD COLUMN price REAL NOT NULL");
        await db.execute("ALTER TABLE items RENAME COLUMN title TO nama_produk");
      }
    },
    );
  }

  // **Mengambil semua data**
  static Future<List<Map<String, dynamic>>> getItems() async {
    try {
      final db = await SQLHelper.db();
      return db.query('items', orderBy: "id DESC"); // Data terbaru di atas
    } catch (e) {
      print("Error getItems: $e");
      return [];
    }
  }

  // **Mengambil satu data berdasarkan ID**
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    try {
      final db = await SQLHelper.db();
      return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
    } catch (e) {
      print("Error getItem: $e");
      return [];
    }
  }

  // **Menambahkan item baru ke database**
  static Future<int> createItem(
      String name, String? description, String? img, int price) async {
    try {
      final db = await SQLHelper.db();
      final data = {
        'nama_produk': name,
        'description': description ?? '',
        'img': img ?? '',
        'price': price
      };
      return await db.insert('items', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error createItem: $e");
      return -1;
    }
  }

  // **Mengupdate item berdasarkan ID**
  static Future<int> updateItem(
      int id, String name, String? description, String? img, int price) async {
    try {
      final db = await SQLHelper.db();
      final data = {
        'nama_produk': name,
        'description': description ?? '',
        'img': img ?? '',
        'price': price
      };
      return await db.update('items', data, where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("Error updateItem: $e");
      return -1;
    }
  }

  // **Menghapus item berdasarkan ID**
  static Future<void> deleteItem(int id) async {
    try {
      final db = await SQLHelper.db();
      await db.delete('items', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("Error deleteItem: $e");
    }
  }
}
