import 'package:sqflite/sqflite.dart';
import '../../models/category.dart';
import '../database.dart';

class CategoryDAO {
  final AppDatabase _db = AppDatabase.instance;

  // Inserir categoria
  Future<int> insert(Category category) async {
    final db = await _db.database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Atualizar categoria
  Future<int> update(Category category) async {
    final db = await _db.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Deletar categoria
  Future<int> delete(String id) async {
    final db = await _db.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Buscar categoria por ID
  Future<Category?> getById(String id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  // Listar todas as categorias
  Future<List<Category>> listAll() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // Listar categorias por tipo
  Future<List<Category>> listByType(CategoryType type) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ? OR type = ?',
      whereArgs: [type.value, CategoryType.both.value],
      orderBy: 'name ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // Verificar se cor está em uso
  Future<bool> colorInUse(String colorHex, {String? excludeId}) async {
    final db = await _db.database;
    String whereClause = 'color_hex = ?';
    List<dynamic> whereArgs = [colorHex];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  // Obter todas as cores em uso
  Future<List<String>> getUsedColors() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      columns: ['color_hex'],
    );

    return maps.map((map) => map['color_hex'] as String).toList();
  }

  // Verificar se categoria tem transações associadas
  Future<bool> hasTransactions(String categoryId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE category_id = ?',
      [categoryId],
    );

    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  // Contar total de categorias
  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM categories',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
