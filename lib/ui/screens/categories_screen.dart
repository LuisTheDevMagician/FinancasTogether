import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../models/category.dart';
import '../../utils/constants.dart';
import 'category_form_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma categoria cadastrada',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'As categorias padrão já foram criadas.\nToque no + para adicionar mais.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Agrupar por tipo
            final incomeCategories = state.categories
                .where((c) =>
                    c.type == CategoryType.income ||
                    c.type == CategoryType.both)
                .toList();
            final outcomeCategories = state.categories
                .where((c) =>
                    c.type == CategoryType.outcome ||
                    c.type == CategoryType.both)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (incomeCategories.isNotEmpty) ...[
                  _buildSectionHeader(
                      context, 'Entradas', Icons.arrow_upward, Colors.green),
                  ...incomeCategories
                      .map((cat) => _buildCategoryCard(context, cat)),
                  const SizedBox(height: 16),
                ],
                if (outcomeCategories.isNotEmpty) ...[
                  _buildSectionHeader(
                      context, 'Saídas', Icons.arrow_downward, Colors.red),
                  ...outcomeCategories
                      .map((cat) => _buildCategoryCard(context, cat)),
                ],
              ],
            );
          } else if (state is CategoriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppConstants.hexToColor(category.colorHex),
            shape: BoxShape.circle,
          ),
          child: Icon(
            category.type == CategoryType.income
                ? Icons.arrow_upward
                : category.type == CategoryType.outcome
                    ? Icons.arrow_downward
                    : Icons.swap_vert,
            color: Colors.white,
          ),
        ),
        title: Text(category.name),
        subtitle: Text(_getTypeLabel(category.type)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryFormScreen(category: category),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () => _confirmDelete(context, category),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(CategoryType type) {
    switch (type) {
      case CategoryType.income:
        return 'Entrada';
      case CategoryType.outcome:
        return 'Saída';
      case CategoryType.both:
        return 'Ambos';
    }
  }

  Future<void> _confirmDelete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CategoryBloc>().add(DeleteCategory(category.id));
    }
  }
}
