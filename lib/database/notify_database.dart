import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotifyDatabase {
  static Database? _database;

  static Future<void> initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fall_detection.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE settings (id INTEGER PRIMARY KEY, fall_detection_enabled INTEGER)',
        );
        await db.insert('settings', {'id': 1, 'fall_detection_enabled': 1});
      },
    );
  }

  static Future<void> saveFallDetectionStatus(bool isEnabled) async {
    await _database!.update(
      'settings',
      {'fall_detection_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<bool?> getFallDetectionStatus() async {
    final List<Map<String, dynamic>> result = await _database!.query(
      'settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isNotEmpty) {
      return result.first['fall_detection_enabled'] == 1;
    }

    return null;
  }
}
