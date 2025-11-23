import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc({required UserRepository repository})
      : _repository = repository,
        super(UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final users = await _repository.getAll();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError('Erro ao carregar usuários: ${e.toString()}'));
    }
  }

  Future<void> _onAddUser(
    AddUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      final colorHex = event.colorHex ?? '#4A90E2'; // Cor padrão
      await _repository.create(name: event.name, colorHex: colorHex);
      emit(const UserOperationSuccess('Usuário criado com sucesso'));

      // Recarregar lista
      final users = await _repository.getAll();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError('Erro ao criar usuário: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _repository.update(event.user);
      emit(const UserOperationSuccess('Usuário atualizado'));

      // Recarregar lista
      final users = await _repository.getAll();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError('Erro ao atualizar usuário: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      emit(const UserOperationSuccess('Usuário deletado'));

      // Recarregar lista
      final users = await _repository.getAll();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError('Erro ao deletar: ${e.toString()}'));
    }
  }
}
