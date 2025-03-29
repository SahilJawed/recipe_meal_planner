import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    print('Initializing database...');
    _database = await _initDB('recipes.db');
    print('Database initialized');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 3, // Increment the version to trigger onUpgrade
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    print('Creating database tables...');
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE recipes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      title TEXT NOT NULL,
      ingredients TEXT NOT NULL,
      steps TEXT NOT NULL,
      isFavorite INTEGER NOT NULL DEFAULT 0,
      PREFERENCE TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id)
      
    )
    ''');
    print('Tables created');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion...');
    if (oldVersion < 2) {
      // Add the users table if it doesn't exist (from previous migration)
      await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
      ''');
      print('Users table created during upgrade');
    }
    if (oldVersion < 3) {
      // Add the userId column to the recipes table
      await db.execute('''
      ALTER TABLE recipes ADD COLUMN userId INTEGER NOT NULL DEFAULT 0
      ''');
      print('Added userId column to recipes table');
      // Note: You can't add a FOREIGN KEY constraint to an existing table in SQLite.
      // If you need the FOREIGN KEY, you'll need to recreate the table (see below).
    }
  }

  Future<int> createUser(String username, String email, String password) async {
    final db = await database;
    final data = {'username': username, 'email': email, 'password': password};
    print('Creating user: $data');
    final id = await db.insert('users', data);
    print('User created with id: $id');
    return id;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    print('Fetching user with email: $email');
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    final user = result.isNotEmpty ? result.first : null;
    print('User fetched: $user');
    return user;
  }

  Future<bool> doesEmailExist(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getRecipes(int userId) async {
    final db = await database;
    print('Fetching recipes for userId: $userId');
    final result = await db.query(
      'recipes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    print('Recipes fetched: $result');
    return result;
  }

  Future<void> addRecipe(int userId, Map<String, dynamic> recipe) async {
    final db = await database;

    final recipeData = {
      'userId': userId,
      'title': recipe['title'],
      'ingredients': recipe['ingredients'],
      'steps': recipe['steps'],
      'isFavorite': recipe['isFavorite'] ?? 0,
      'preference': recipe['preference'],
    };
    print('Inserting recipe: $recipeData');
    await db.insert('recipes', recipeData);
    print('Recipe inserted');
  }

  Future<void> updateFavorite(int id, int isFavorite) async {
    final db = await database;
    print('Updating favorite for id $id to $isFavorite');
    await db.update(
      'recipes',
      {'isFavorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Favorite updated');
  }

  Future<void> deleteRecipe(int id) async {
    final db = await database;
    print('Deleting recipe with id: $id');
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
    print('Recipe deleted');
  }

  // In DatabaseHelper
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'recipes.db');
    await deleteDatabase(path);
    print('Database deleted');
  }

  Future<List<Map<String, dynamic>>> getRecipesByPreference(
    int userId,
    String preference,
  ) async {
    final db = await database;
    print('Fetching recipes for userId: $userId with preference: $preference');
    final result = await db.query(
      'recipes',
      where: 'userId = ? AND preference = ?',
      whereArgs: [userId, preference],
    );
    print(
      'Recipes fetched with preference: $preference, count: ${result.length}',
    );
    return result;
  }
}
