import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Menentukan path database di lokal perangkat
    String path = join(await getDatabasesPath(), 'weather_app.db');

    // Membuka atau membuat database baru
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE cities(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
        );
      },
    );
  }

  // Fungsi untuk menyimpan kota baru secara permanen
  Future<int> insertCity(String cityName) async {
    final db = await database;
    return await db.insert(
      'cities',
      {'name': cityName},
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Jika duplikat, akan ditimpa yang baru
    );
  }

  // Fungsi untuk mengambil seluruh daftar kota yang tersimpan
  Future<List<Map<String, dynamic>>> getCities() async {
    final db = await database;
    return await db.query('cities');
  }

  // Fungsi untuk menghapus kota dari daftar favorit
  Future<int> deleteCity(String cityName) async {
    final db = await database;
    return await db.delete(
      'cities',
      where: 'LOWER(name) = ?',
      whereArgs: [cityName.toLowerCase()],
    );
  }
}
