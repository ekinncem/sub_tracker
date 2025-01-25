import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subscription.dart';

class Subscription {
  final int? id;
  final String name;
  final double price;
  final String date;

  Subscription({
    this.id,
    required this.name,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'date': date,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      date: map['date'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('subscriptions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        date TEXT
      )
    ''');
  }

  Future<int> insertSubscription(Subscription subscription) async {
    final db = await instance.database;
    return await db.insert('subscriptions', subscription.toMap());
  }

  Future<List<Subscription>> getAllSubscriptions() async {
    final db = await instance.database;
    final maps = await db.query('subscriptions');
    return maps.map((map) => Subscription.fromMap(map)).toList();
  }

  Future<int> updateSubscription(Subscription subscription) async {
    final db = await instance.database;
    return await db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<int> deleteSubscription(int id) async {
    final db = await instance.database;
    return await db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}