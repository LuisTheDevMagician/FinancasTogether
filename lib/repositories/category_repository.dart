import '../data/daos/category_dao.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final CategoryDAO _categoryDAO = CategoryDAO();
  final Uuid _uuid = const Uuid();

  Future<Category> create({
    required String name,
    required CategoryType type,
    String? colorHex,
  }) async {
    // Se cor não fornecida, buscar uma disponível
    final String finalColor = colorHex ?? await getAvailableColor();

    final category = Category(
      id: _uuid.v4(),
      name: name,
      type: type,
      colorHex: finalColor,
      createdAt: DateTime.now(),
    );

    await _categoryDAO.insert(category);
    return category;
  }

  Future<void> update(Category category) async {
    await _categoryDAO.update(category);
  }

  Future<void> delete(String id) async {
    // Verificar se há transações antes de deletar
    final hasTransactions = await _categoryDAO.hasTransactions(id);
    if (hasTransactions) {
      throw Exception(
        'Não é possível deletar categoria com transações associadas',
      );
    }
    await _categoryDAO.delete(id);
  }

  Future<Category?> getById(String id) async {
    return await _categoryDAO.getById(id);
  }

  Future<List<Category>> getAll() async {
    return await _categoryDAO.listAll();
  }

  Future<List<Category>> getByType(CategoryType type) async {
    return await _categoryDAO.listByType(type);
  }

  Future<bool> colorInUse(String colorHex, {String? excludeId}) async {
    return await _categoryDAO.colorInUse(colorHex, excludeId: excludeId);
  }

  // Busca a primeira cor disponível não usada
  Future<String> getAvailableColor() async {
    final usedColors = await _categoryDAO.getUsedColors();

    for (final colorHex in AppConstants.availableColorHexList) {
      if (!usedColors.contains(colorHex)) {
        return colorHex;
      }
    }

    // Se todas as cores estão em uso, retorna uma aleatória
    return AppConstants.availableColorHexList[DateTime.now()
            .millisecondsSinceEpoch %
        AppConstants.availableColorHexList.length];
  }

  Future<List<String>> getUsedColors() async {
    return await _categoryDAO.getUsedColors();
  }

  Future<int> count() async {
    return await _categoryDAO.count();
  }
}
