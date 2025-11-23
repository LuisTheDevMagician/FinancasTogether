import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc({required CategoryRepository repository})
      : _repository = repository,
        super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadCategoriesByType>(_onLoadCategoriesByType);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Erro ao carregar categorias: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCategoriesByType(
    LoadCategoriesByType event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final categories = await _repository.getByType(event.type);
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Erro ao carregar categorias: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.create(
        name: event.name,
        type: event.type,
        colorHex: event.colorHex,
      );
      emit(const CategoryOperationSuccess('Categoria criada com sucesso'));

      // Recarregar lista
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Erro ao criar categoria: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.update(event.category);
      emit(const CategoryOperationSuccess('Categoria atualizada'));

      // Recarregar lista
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Erro ao atualizar categoria: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      emit(const CategoryOperationSuccess('Categoria deletada'));

      // Recarregar lista
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Erro ao deletar: ${e.toString()}'));
    }
  }
}
