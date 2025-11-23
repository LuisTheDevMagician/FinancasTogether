import 'package:sqflite/sqflite.dart';
import '../../models/transaction.dart' as models;
import '../database.dart';

class TransactionDAO {
  final AppDatabase _db = AppDatabase.instance;

  // Inserir transação
  Future<int> insert(models.Transaction transaction) async {
    final db = await _db.database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Atualizar transação
  Future<int> update(models.Transaction transaction) async {
    final db = await _db.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Deletar transação
  Future<int> delete(String id) async {
    final db = await _db.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Buscar transação por ID
  Future<models.Transaction?> getById(String id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return models.Transaction.fromMap(maps.first);
  }

  // Listar todas as transações
  Future<List<models.Transaction>> listAll() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC, created_at DESC',
    );

    return maps.map((map) => models.Transaction.fromMap(map)).toList();
  }

  // Listar transações com filtros
  Future<List<models.Transaction>> listByFilter({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? categoryId,
    models.TransactionType? type,
    int? limit,
    int? offset,
  }) async {
    final db = await _db.database;

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (fromDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }

    if (toDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }

    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (categoryId != null) {
      whereClauses.add('category_id = ?');
      whereArgs.add(categoryId);
    }

    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type.value);
    }

    final String? whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => models.Transaction.fromMap(map)).toList();
  }

  // Obter soma total por tipo no período
  Future<double> getTotalByType({
    required models.TransactionType type,
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? categoryId,
  }) async {
    final db = await _db.database;

    List<String> whereClauses = ['type = ?'];
    List<dynamic> whereArgs = [type.value];

    if (fromDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }

    if (toDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }

    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (categoryId != null) {
      whereClauses.add('category_id = ?');
      whereArgs.add(categoryId);
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE ${whereClauses.join(' AND ')}',
      whereArgs,
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Obter transações agrupadas por categoria
  Future<Map<String, double>> getGroupedByCategory({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    models.TransactionType? type,
  }) async {
    final db = await _db.database;

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (fromDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }

    if (toDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }

    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type.value);
    }

    String whereString =
        whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final result = await db.rawQuery(
      'SELECT category_id, SUM(amount) as total FROM transactions $whereString GROUP BY category_id',
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return Map.fromEntries(
      result.map(
        (row) => MapEntry(
          row['category_id'] as String,
          (row['total'] as num).toDouble(),
        ),
      ),
    );
  }

  // Contar total de transações
  Future<int> count({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? categoryId,
    models.TransactionType? type,
  }) async {
    final db = await _db.database;

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (fromDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }

    if (toDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }

    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (categoryId != null) {
      whereClauses.add('category_id = ?');
      whereArgs.add(categoryId);
    }

    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type.value);
    }

    String whereString =
        whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions $whereString',
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Deletar todas as transações de um usuário
  Future<int> deleteByUser(String userId) async {
    final db = await _db.database;
    return await db.delete(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
