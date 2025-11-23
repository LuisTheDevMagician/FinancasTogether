import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_event.dart';
import 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(const FilterState()) {
    on<SetPeriod>(_onSetPeriod);
    on<SetUser>(_onSetUser);
    on<SetCategory>(_onSetCategory);
    on<SetTransactionType>(_onSetTransactionType);
    on<ResetFilters>(_onResetFilters);
  }

  void _onSetPeriod(SetPeriod event, Emitter<FilterState> emit) {
    emit(state.copyWith(period: event.period));
  }

  void _onSetUser(SetUser event, Emitter<FilterState> emit) {
    if (event.userId == null) {
      emit(state.copyWith(clearUser: true));
    } else {
      emit(state.copyWith(userId: event.userId));
    }
  }

  void _onSetCategory(SetCategory event, Emitter<FilterState> emit) {
    if (event.categoryId == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(categoryId: event.categoryId));
    }
  }

  void _onSetTransactionType(
    SetTransactionType event,
    Emitter<FilterState> emit,
  ) {
    if (event.type == null) {
      emit(state.copyWith(clearType: true));
    } else {
      emit(state.copyWith(type: event.type));
    }
  }

  void _onResetFilters(ResetFilters event, Emitter<FilterState> emit) {
    emit(const FilterState());
  }
}
