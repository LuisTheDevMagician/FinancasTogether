import 'package:sqflite/sqflite.dart';
import '../../models/user.dart';
import '../database.dart';

class UserDAO {
  final AppDatabase _db = AppDatabase.instance;

  // Inserir usuário
  Future<int> insert(User user) async {
    final db = await _db.database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Atualizar usuário
  Future<int> update(User user) async {
    final db = await _db.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Deletar usuário
  Future<int> delete(String id) async {
    final db = await _db.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Buscar usuário por ID
  Future<User?> getById(String id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Listar todos os usuários
  Future<List<User>> listAll() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Verificar se existe usuário com nome específico
  Future<bool> existsByName(String name, {String? excludeId}) async {
    final db = await _db.database;
    String whereClause = 'LOWER(name) = ?';
    List<dynamic> whereArgs = [name.toLowerCase()];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
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
      'users',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  // Contar total de usuários
  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
