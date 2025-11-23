import 'package:equatable/equatable.dart';
import '../../utils/constants.dart';
import '../../models/transaction.dart';

class FilterState extends Equatable {
  final Period period;
  final String? userId;
  final String? categoryId;
  final TransactionType? type;

  const FilterState({
    this.period = Period.month,
    this.userId,
    this.categoryId,
    this.type,
  });

  // Calcula datas de início e fim baseadas no período
  DateTime get startDate {
    final now = DateTime.now();
    switch (period) {
      case Period.day:
        return DateTime(now.year, now.month, now.day);
      case Period.week:
        final weekday = now.weekday;
        return DateTime(now.year, now.month, now.day - (weekday - 1));
      case Period.month:
        return DateTime(now.year, now.month, 1);
      case Period.year:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    switch (period) {
      case Period.day:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case Period.week:
        final weekday = now.weekday;
        return DateTime(
          now.year,
          now.month,
          now.day + (7 - weekday),
          23,
          59,
          59,
        );
      case Period.month:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case Period.year:
        return DateTime(now.year, 12, 31, 23, 59, 59);
    }
  }

  FilterState copyWith({
    Period? period,
    String? userId,
    String? categoryId,
    TransactionType? type,
    bool clearUser = false,
    bool clearCategory = false,
    bool clearType = false,
  }) {
    return FilterState(
      period: period ?? this.period,
      userId: clearUser ? null : (userId ?? this.userId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      type: clearType ? null : (type ?? this.type),
    );
  }

  @override
  List<Object?> get props => [period, userId, categoryId, type];
}
