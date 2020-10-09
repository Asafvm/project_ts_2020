import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:teamshare/providers/applogger.dart';

class DBHelper {
  static Future<Database> database() async {
    final String dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'test.db'),
        onCreate: (db, version) {
      Applogger.consoleLog(
          MessegeType.info, 'New database create: ${db.path} version $version');

      return db.execute(
          'CREATE TABLE parts(id TEXT PRIMARY KEY, description TEXT, device TEXT');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }
}
