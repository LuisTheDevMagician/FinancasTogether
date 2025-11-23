import 'package:equatable/equatable.dart';
import '../../models/transaction.dart' as models;

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

class LoadTransactionsByFilter extends TransactionEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? userId;
  final String? categoryId;
  final models.TransactionType? type;

  const LoadTransactionsByFilter({
    this.fromDate,
    this.toDate,
    this.userId,
    this.categoryId,
    this.type,
  });

  @override
  List<Object?> get props => [fromDate, toDate, userId, categoryId, type];
}

class AddTransaction extends TransactionEvent {
  final String userId;
  final String categoryId;
  final models.TransactionType type;
  final double amount;
  final DateTime date;
  final String? note;

  const AddTransaction({
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [userId, categoryId, type, amount, date, note];
}

class UpdateTransaction extends TransactionEvent {
  final models.Transaction transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}
