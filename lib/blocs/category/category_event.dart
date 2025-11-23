import 'package:equatable/equatable.dart';
import '../../models/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class LoadCategoriesByType extends CategoryEvent {
  final CategoryType type;

  const LoadCategoriesByType(this.type);

  @override
  List<Object?> get props => [type];
}

class AddCategory extends CategoryEvent {
  final String name;
  final CategoryType type;
  final String? colorHex;

  const AddCategory({
    required this.name,
    required this.type,
    this.colorHex,
  });

  @override
  List<Object?> get props => [name, type, colorHex];
}

class UpdateCategory extends CategoryEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}
