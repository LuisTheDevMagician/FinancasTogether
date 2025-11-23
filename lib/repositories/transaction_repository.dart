import '../data/daos/transaction_dao.dart';
import '../models/transaction.dart' as models;
import 'package:uuid/uuid.dart';

class TransactionRepository {
  final TransactionDAO _transactionDAO = TransactionDAO();
  final Uuid _uuid = const Uuid();

  Future<models.Transaction> create({
    required String userId,
    required String categoryId,
    required models.TransactionType type,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final transaction = models.Transaction(
      id: _uuid.v4(),
      userId: userId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );

    await _transactionDAO.insert(transaction);
    return transaction;
  }

  Future<void> update(models.Transaction transaction) async {
    await _transactionDAO.update(transaction);
  }

  Future<void> delete(String id) async {
    await _transactionDAO.delete(id);
  }

  Future<models.Transaction?> getById(String id) async {
    return await _transactionDAO.getById(id);
  }

  Future<List<models.Transaction>> getAll() async {
    return await _transactionDAO.listAll();
  }

  Future<List<models.Transaction>> getByFilter({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? categoryId,
    models.TransactionType? type,
    int? limit,
    int? offset,
  }) async {
    return await _transactionDAO.listByFilter(
      fromDate: fromDate,
      toDate: toDate,
      userId: userId,
      categoryId: categoryId,
      type: type,
      limit: limit,
      offset: offset,
    );
  }

  Future<double> getTotalByType({
    required models.TransactionType type,
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? categoryId,
  }) async {
    return await _transactionDAO.getTotalByType(
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      userId: userId,
      categoryId: categoryId,
    );
  }

  Future<Map<String, double>> getGroupedByCategory({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    models.TransactionType? type,
  }) async {
    return await _transactionDAO.getGroupedByCategory(
      fromDate: fromDate,
      toDate: toDate,
      userId: userId,
      type: type,
    );
  }

  Future<int> count({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? categoryId,
    models.TransactionType? type,
  }) async {
    return await _transactionDAO.count(
      fromDate: fromDate,
      toDate: toDate,
      userId: userId,
      categoryId: categoryId,
      type: type,
    );
  }

  Future<void> deleteByUser(String userId) async {
    await _transactionDAO.deleteByUser(userId);
  }
}
