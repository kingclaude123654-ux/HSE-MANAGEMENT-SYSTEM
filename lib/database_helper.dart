import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'incident_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('incidents.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE incidents (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      refNumber TEXT NOT NULL,
      dateReported TEXT NOT NULL,
      severity TEXT NOT NULL,
      classifications TEXT NOT NULL,
      project TEXT NOT NULL,
      worksite TEXT NOT NULL,
      department TEXT NOT NULL,
      exactLocation TEXT NOT NULL,
      personName TEXT NOT NULL,
      personCompany TEXT NOT NULL,
      why1 TEXT,
      why2 TEXT,
      why3 TEXT,
      why4 TEXT,
      why5 TEXT,
      directCause TEXT,
      rootCause TEXT,
      actionItem TEXT,
      actionAssignee TEXT,
      actionStatus TEXT
    )
    ''');
  }

  Future<int> insertIncident(Incident incident) async {
    final db = await instance.database;
    return await db.insert('incidents', incident.toMap());
  }

  Future<List<Incident>> fetchAllIncidents() async {
    final db = await instance.database;
    final result = await db.query('incidents', orderBy: 'id DESC');
    return result.map((json) => Incident.fromMap(json)).toList();
  }

  Future<int> updateIncidentAction(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'incidents',
      {'actionStatus': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
