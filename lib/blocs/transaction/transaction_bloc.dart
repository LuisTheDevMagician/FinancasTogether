import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../repositories/transaction_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;

  // Armazenar último filtro para recarregar após operações
  // Apenas datas e userId - não incluir type/categoryId para evitar bugs
  DateTime? _lastFromDate;
  DateTime? _lastToDate;
  String? _lastUserId;

  TransactionBloc({required TransactionRepository repository})
      : _repository = repository,
        super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionsByFilter>(_onLoadTransactionsByFilter);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionsLoading());
    try {
      final transactions = await _repository.getAll();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('Erro ao carregar transações: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransactionsByFilter(
    LoadTransactionsByFilter event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionsLoading());
    try {
      // Salvar filtros para reutilizar após operações
      // Não salvamos type nem categoryId para evitar filtros indesejados
      _lastFromDate = event.fromDate;
      _lastToDate = event.toDate;
      _lastUserId = event.userId;

      final transactions = await _repository.getByFilter(
        fromDate: event.fromDate,
        toDate: event.toDate,
        userId: event.userId,
        categoryId: event.categoryId,
        type: event.type,
      );
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('Erro ao carregar transações: ${e.toString()}'));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.create(
        userId: event.userId,
        categoryId: event.categoryId,
        type: event.type,
        amount: event.amount,
        date: event.date,
        note: event.note,
      );
      emit(const TransactionOperationSuccess('Transação criada com sucesso'));

      // Recarregar lista usando os filtros salvos (sem type/categoryId)
      final transactions = await _repository.getByFilter(
        fromDate: _lastFromDate,
        toDate: _lastToDate,
        userId: _lastUserId,
      );
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('Erro ao criar transação: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.update(event.transaction);
      emit(const TransactionOperationSuccess('Transação atualizada'));

      // Recarregar lista usando os filtros salvos (sem type/categoryId)
      final transactions = await _repository.getByFilter(
        fromDate: _lastFromDate,
        toDate: _lastToDate,
        userId: _lastUserId,
      );
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('Erro ao atualizar transação: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      emit(const TransactionOperationSuccess('Transação deletada'));

      // Recarregar lista usando os filtros salvos (sem type/categoryId)
      final transactions = await _repository.getByFilter(
        fromDate: _lastFromDate,
        toDate: _lastToDate,
        userId: _lastUserId,
      );
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('Erro ao deletar: ${e.toString()}'));
    }
  }
}
