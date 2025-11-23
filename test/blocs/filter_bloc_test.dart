import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:financaspessoais/blocs/filter/filter_bloc.dart';
import 'package:financaspessoais/blocs/filter/filter_event.dart';
import 'package:financaspessoais/blocs/filter/filter_state.dart';
import 'package:financaspessoais/utils/constants.dart';
import 'package:financaspessoais/models/transaction.dart';

void main() {
  group('FilterBloc', () {
    late FilterBloc filterBloc;

    setUp(() {
      filterBloc = FilterBloc();
    });

    tearDown(() {
      filterBloc.close();
    });

    test('initial state is correct', () {
      expect(
        filterBloc.state,
        const FilterState(
          period: Period.month,
          userId: null,
          categoryId: null,
          type: null,
        ),
      );
    });

    blocTest<FilterBloc, FilterState>(
      'emits new period when SetPeriod is added',
      build: () => filterBloc,
      act: (bloc) => bloc.add(const SetPeriod(Period.week)),
      expect: () => [
        const FilterState(
          period: Period.week,
          userId: null,
          categoryId: null,
          type: null,
        ),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits new userId when SetUser is added',
      build: () => filterBloc,
      act: (bloc) => bloc.add(const SetUser('user-123')),
      expect: () => [
        const FilterState(
          period: Period.month,
          userId: 'user-123',
          categoryId: null,
          type: null,
        ),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'clears userId when SetUser is added with null',
      build: () => filterBloc,
      seed: () => const FilterState(period: Period.month, userId: 'user-123'),
      act: (bloc) => bloc.add(const SetUser(null)),
      expect: () => [
        const FilterState(
          period: Period.month,
          userId: null,
          categoryId: null,
          type: null,
        ),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits new categoryId when SetCategory is added',
      build: () => filterBloc,
      act: (bloc) => bloc.add(const SetCategory('cat-456')),
      expect: () => [
        const FilterState(
          period: Period.month,
          userId: null,
          categoryId: 'cat-456',
          type: null,
        ),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'emits new type when SetTransactionType is added',
      build: () => filterBloc,
      act: (bloc) => bloc.add(const SetTransactionType(TransactionType.income)),
      expect: () => [
        const FilterState(
          period: Period.month,
          userId: null,
          categoryId: null,
          type: TransactionType.income,
        ),
      ],
    );

    blocTest<FilterBloc, FilterState>(
      'resets to initial state when ResetFilters is added',
      build: () => filterBloc,
      seed: () => const FilterState(
        period: Period.week,
        userId: 'user-123',
        categoryId: 'cat-456',
        type: TransactionType.outcome,
      ),
      act: (bloc) => bloc.add(const ResetFilters()),
      expect: () => [
        const FilterState(
          period: Period.month,
          userId: null,
          categoryId: null,
          type: null,
        ),
      ],
    );

    test('FilterState startDate and endDate work correctly for MONTH', () {
      final now = DateTime.now();
      const state = FilterState(period: Period.month);

      expect(state.startDate.year, now.year);
      expect(state.startDate.month, now.month);
      expect(state.startDate.day, 1);

      expect(state.endDate.year, now.year);
      expect(state.endDate.month, now.month);
    });

    test('FilterState startDate and endDate work correctly for WEEK', () {
      const state = FilterState(period: Period.week);

      // Deve retornar segunda-feira da semana atual
      expect(state.startDate.weekday, 1);

      // Deve retornar domingo da semana atual
      expect(state.endDate.weekday, 7);
    });

    test('FilterState copyWith works correctly', () {
      const state = FilterState(period: Period.month, userId: 'user-1');

      final newState = state.copyWith(period: Period.week, categoryId: 'cat-1');

      expect(newState.period, Period.week);
      expect(newState.userId, 'user-1'); // Mantém o valor antigo
      expect(newState.categoryId, 'cat-1');
    });

    test('FilterState copyWith clears values correctly', () {
      const state = FilterState(
        period: Period.month,
        userId: 'user-1',
        categoryId: 'cat-1',
        type: TransactionType.income,
      );

      final newState = state.copyWith(
        clearUser: true,
        clearCategory: true,
        clearType: true,
      );

      expect(newState.userId, null);
      expect(newState.categoryId, null);
      expect(newState.type, null);
      expect(newState.period, Period.month); // Mantém período
    });
  });
}
