import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationDatabase {
  static final LocationDatabase instance = LocationDatabase._init();
  static Database? _database;
  LocationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
        join(await getDatabasesPath(), 'evidyut_tracker.db'),
        version: 1,
        onCreate: (db, version) {
          return db.execute(
              "CREATE TABLE locations(id INTEGER PRIMARY KEY AUTOINCREMENT, latitude TEXT, longitude TEXT, timestamp TEXT)"
          );
        }
    );
    return _database!;
  }

  Future<void> insertLocation(String lat, String lng, String formattedTime) async {
    final db = await instance.database;
    await db.insert('locations', {
      'latitude': lat,
      'longitude': lng,
      'timestamp': formattedTime
    });
    print("SQLite Save: $lat, $lng | $formattedTime");
  }

  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final db = await instance.database;
    return await db.query('locations', orderBy: 'id ASC');
  }

  Future<void> deleteLocation(int id) async {
    final db = await instance.database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }
}