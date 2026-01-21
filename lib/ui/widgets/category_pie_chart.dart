import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

class CategoryPieChart extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;

  const CategoryPieChart({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return _buildEmptyState();
    }

    final data = _calculateCategoryData();
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribuição por Categoria',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: _buildSections(data),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildLegend(data),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Nenhuma transação no período',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, CategoryData> _calculateCategoryData() {
    final Map<String, CategoryData> categoryMap = {};
    double total = 0;

    for (var transaction in widget.transactions) {
      total += transaction.amount;
      final category = widget.categories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => Category(
          id: '',
          name: 'Sem Categoria',
          type: CategoryType.both,
          colorHex: '#999999',
          createdAt: DateTime.now(),
        ),
      );

      if (categoryMap.containsKey(category.id)) {
        categoryMap[category.id]!.amount += transaction.amount;
      } else {
        categoryMap[category.id] = CategoryData(
          name: category.name,
          amount: transaction.amount,
          color: _parseColor(category.colorHex),
        );
      }
    }

    // Calcular percentuais
    categoryMap.forEach((key, value) {
      value.percentage = (value.amount / total) * 100;
    });

    return categoryMap;
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  List<PieChartSectionData> _buildSections(Map<String, CategoryData> data) {
    int index = 0;
    return data.values.map((categoryData) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 70.0 : 60.0;
      index++;

      return PieChartSectionData(
        color: categoryData.color,
        value: categoryData.amount,
        title: '${categoryData.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).round()),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  categoryData.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: categoryData.color,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, CategoryData> data) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.values.map((categoryData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: categoryData.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryData.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'R\$ ${categoryData.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CategoryData {
  final String name;
  double amount;
  final Color color;
  double percentage = 0;

  CategoryData({
    required this.name,
    required this.amount,
    required this.color,
  });
}
