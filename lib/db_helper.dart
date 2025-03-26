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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    print('Creating database table...');
    await db.execute('''
    CREATE TABLE recipes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      ingredients TEXT NOT NULL,
      steps TEXT NOT NULL,
      isFavorite INTEGER NOT NULL DEFAULT 0
    )
    ''');
    print('Table created');
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    print('Fetching recipes from database...');
    final result = await db.query('recipes');
    print('Recipes fetched: $result');
    return result;
  }

  Future<void> addRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    print('Inserting recipe: $recipe');
    await db.insert('recipes', recipe);
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
}
