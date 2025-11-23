import 'package:equatable/equatable.dart';

enum TransactionType {
  income('INCOME'),
  outcome('OUTCOME');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.income,
    );
  }
}

class Transaction extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  // Factory para criar a partir do Map (SQFlite)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      type: TransactionType.fromString(map['type'] as String),
      amount: map['amount'] as double,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Converter para Map (SQFlite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'type': type.value,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // CopyWith para imutabilidade
  Transaction copyWith({
    String? id,
    String? userId,
    String? categoryId,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    type,
    amount,
    date,
    note,
    createdAt,
  ];

  @override
  String toString() =>
      'Transaction(id: $id, userId: $userId, type: ${type.value}, amount: $amount)';
}
