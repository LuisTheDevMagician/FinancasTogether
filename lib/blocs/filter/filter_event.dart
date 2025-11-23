import 'package:equatable/equatable.dart';
import '../../utils/constants.dart';
import '../../models/transaction.dart';

abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object?> get props => [];
}

class SetPeriod extends FilterEvent {
  final Period period;

  const SetPeriod(this.period);

  @override
  List<Object?> get props => [period];
}

class SetUser extends FilterEvent {
  final String? userId;

  const SetUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SetCategory extends FilterEvent {
  final String? categoryId;

  const SetCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SetTransactionType extends FilterEvent {
  final TransactionType? type;

  const SetTransactionType(this.type);

  @override
  List<Object?> get props => [type];
}

class ResetFilters extends FilterEvent {
  const ResetFilters();
}
