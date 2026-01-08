
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/shopping_item.dart';
import '../models/shopping_list.dart';
import '../models/user.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // ---------------- DATABASE ----------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smartshop.db');

    return await openDatabase(
      path,
      version: 8,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON');

        // USERS TABLE
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          );
        ''');

        // SHOPPING LISTS
        await db.execute('''
          CREATE TABLE shopping_lists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            userId INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          );
        ''');

        // SHOPPING ITEMS
        await db.execute('''
          CREATE TABLE shopping_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            listId INTEGER,
            name TEXT,
            isDone INTEGER,
            price REAL DEFAULT 0,
            quantity INTEGER DEFAULT 1,
            FOREIGN KEY (listId) REFERENCES shopping_lists(id) ON DELETE CASCADE
          );
        ''');

        // BUDGET TABLE
        await db.execute('''
          CREATE TABLE budget(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER UNIQUE,
            total_budget REAL,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('PRAGMA foreign_keys = ON');

        if (oldVersion < 6) {
          try {
            await db.execute(
              'ALTER TABLE shopping_lists ADD COLUMN userId INTEGER',
            );
          } catch (_) {}
        }

        if (oldVersion < 7) {
          try {
            await db.execute(
              'ALTER TABLE shopping_items ADD COLUMN price REAL DEFAULT 0',
            );
            await db.execute(
              'ALTER TABLE shopping_items ADD COLUMN quantity INTEGER DEFAULT 1',
            );
          } catch (_) {}
        }

        if (oldVersion < 8) {
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN userId INTEGER');
          } catch (_) {}
        }
      },
    );
  }

  // ---------------- USERS ----------------
  Future<int?> registerUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;

    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return User.fromMap(result.first);

    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) return User.fromMap(result.first);

    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // ---------------- SHOPPING LISTS ----------------
  Future<int> insertList(ShoppingList list) async {
    final db = await database;
    return await db.insert('shopping_lists', list.toMap());
  }

  Future<List<ShoppingList>> getListsByUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'shopping_lists',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => ShoppingList.fromMap(map)).toList();
  }

  Future<int> deleteList(int id) async {
    final db = await database;
    return await db.delete('shopping_lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateList(ShoppingList list) async {
    final db = await database;
    return await db.update(
      'shopping_lists',
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  // ---------------- SHOPPING ITEMS ----------------
  Future<int> insertItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert('shopping_items', item.toMap());
  }

  Future<List<ShoppingItem>> getItems(int listId) async {
    final db = await database;
    final maps = await db.query(
      'shopping_items',
      where: 'listId = ?',
      whereArgs: [listId],
    );
    return maps.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  Future<int> updateItem(ShoppingItem item) async {
    final db = await database;
    return await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- BUDGET ----------------
  Future<void> saveBudget(double amount, int userId) async {
    final db = await database;

    // Check if budget exists for this user
    final existing = await db.query(
      'budget',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (existing.isNotEmpty) {
      // Update existing budget
      await db.update(
        'budget',
        {'total_budget': amount},
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } else {
      // Insert new budget
      await db.insert('budget', {'userId': userId, 'total_budget': amount});
    }
  }

  Future<double> getBudget(int userId) async {
    final db = await database;
    final result = await db.query(
      'budget',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) return result.first['total_budget'] as double;
    return 0.0;
  }

  Future<double> getTotalSpent(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(si.price * si.quantity) as total
      FROM shopping_items si
      INNER JOIN shopping_lists sl ON si.listId = sl.id
      WHERE si.isDone = 1 AND sl.userId = ?
    ''',
      [userId],
    );

    return result.first['total'] == null
        ? 0.0
        : result.first['total'] as double;
  }

  // Get remaining budget for a user
  Future<double> getRemainingBudget(int userId) async {
    final totalBudget = await getBudget(userId);
    final totalSpent = await getTotalSpent(userId);
    return totalBudget - totalSpent;
  }

  // Delete budget for a user
  Future<int> deleteBudget(int userId) async {
    final db = await database;
    return await db.delete('budget', where: 'userId = ?', whereArgs: [userId]);
  }
}
