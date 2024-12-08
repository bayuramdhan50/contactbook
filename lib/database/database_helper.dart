import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static DatabaseHelper get instance => _instance;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE contacts ADD COLUMN isFavorite INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        avatar TEXT,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertContact(Map<String, dynamic> contact) async {
    Database db = await database;
    return await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    Database db = await database;
    return await db.query('contacts', orderBy: 'name');
  }

  Future<int> updateContact(Map<String, dynamic> contact) async {
    Database db = await database;
    return await db.update(
      'contacts',
      contact,
      where: 'id = ?',
      whereArgs: [contact['id']],
    );
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<void> toggleFavorite(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      {'isFavorite': contact.isFavorite == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }
}
