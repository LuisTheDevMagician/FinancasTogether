import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';

class PeriodBarChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String periodLabel;

  const PeriodBarChart({
    super.key,
    required this.transactions,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    final data = _calculateData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entradas x Saídas - $periodLabel',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data['maxY'] as double,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncome = rodIndex == 0;
                      final label = isIncome ? 'Entradas' : 'Saídas';
                      return BarTooltipItem(
                        '$label\nR\$ ${rod.toY.toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final groups =
                            data['groups'] as List<BarChartGroupData>;
                        if (value.toInt() >= 0 &&
                            value.toInt() < groups.length) {
                          final dateLabels = data['dateLabels'] as List<String>;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dateLabels[value.toInt()],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0');
                        return Text(
                          _formatCurrency(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (data['maxY'] as double) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: data['groups'] as List<BarChartGroupData>,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
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
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
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

  Map<String, dynamic> _calculateData() {
    if (periodLabel.toLowerCase().contains('dia')) {
      return _calculateDailyData();
    } else if (periodLabel.toLowerCase().contains('semana')) {
      return _calculateWeeklyDataForWeek();
    } else if (periodLabel.toLowerCase().contains('mês')) {
      return _calculateWeeklyDataForMonth();
    } else if (periodLabel.toLowerCase().contains('ano')) {
      return _calculateMonthlyData();
    }
    return _calculateDailyData(); // fallback
  }

  // Dados diários (para filtro "Dia")
  Map<String, dynamic> _calculateDailyData() {
    final Map<DateTime, Map<String, double>> dailyData = {};

    for (var transaction in transactions) {
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = {'income': 0.0, 'outcome': 0.0};
      }

      if (transaction.type == TransactionType.income) {
        dailyData[dateKey]!['income'] =
            dailyData[dateKey]!['income']! + transaction.amount;
      } else {
        dailyData[dateKey]!['outcome'] =
            dailyData[dateKey]!['outcome']! + transaction.amount;
      }
    }

    final sortedDates = dailyData.keys.toList()..sort();
    final displayDates = sortedDates.length > 7
        ? sortedDates.sublist(sortedDates.length - 7)
        : sortedDates;

    final dateLabels =
        displayDates.map((date) => DateFormat('dd/MM').format(date)).toList();

    final List<BarChartGroupData> groups = [];
    double maxY = 0;

    for (int i = 0; i < displayDates.length; i++) {
      final date = displayDates[i];
      final income = dailyData[date]!['income']!;
      final outcome = dailyData[date]!['outcome']!;

      maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: outcome,
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
    };
  }

  // Dados por dia da semana (para filtro "Semana")
  Map<String, dynamic> _calculateWeeklyDataForWeek() {
    final Map<int, Map<String, double>> weekData = {
      0: {'income': 0.0, 'outcome': 0.0}, // Domingo
      1: {'income': 0.0, 'outcome': 0.0}, // Segunda
      2: {'income': 0.0, 'outcome': 0.0}, // Terça
      3: {'income': 0.0, 'outcome': 0.0}, // Quarta
      4: {'income': 0.0, 'outcome': 0.0}, // Quinta
      5: {'income': 0.0, 'outcome': 0.0}, // Sexta
      6: {'income': 0.0, 'outcome': 0.0}, // Sábado
    };

    for (var transaction in transactions) {
      // Dart weekday: 1=Monday, 7=Sunday
      // Converter para: 0=Sunday, 1=Monday, ..., 6=Saturday
      final weekday = transaction.date.weekday %
          7; // 7%7=0 (Sunday), 1%7=1 (Monday), ..., 6%7=6 (Saturday)

      if (transaction.type == TransactionType.income) {
        weekData[weekday]!['income'] =
            weekData[weekday]!['income']! + transaction.amount;
      } else {
        weekData[weekday]!['outcome'] =
            weekData[weekday]!['outcome']! + transaction.amount;
      }
    }

    final dateLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final List<BarChartGroupData> groups = [];
    double maxY = 0;

    for (int i = 0; i < 7; i++) {
      final income = weekData[i]!['income']!;
      final outcome = weekData[i]!['outcome']!;

      maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: outcome,
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
    };
  }

  // Dados por semana (para filtro "Mês")
  Map<String, dynamic> _calculateWeeklyDataForMonth() {
    final Map<String, Map<String, double>> weeklyData = {};

    for (var transaction in transactions) {
      final transactionDate = transaction.date;
      final weekday = transactionDate.weekday % 7;
      final sundayOfWeek = transactionDate.subtract(Duration(days: weekday));
      final saturdayOfWeek = sundayOfWeek.add(const Duration(days: 6));

      final weekKey =
          '${DateFormat('dd/MM').format(sundayOfWeek)}-${DateFormat('dd/MM').format(saturdayOfWeek)}';

      if (!weeklyData.containsKey(weekKey)) {
        weeklyData[weekKey] = {
          'income': 0.0,
          'outcome': 0.0,
          'date': sundayOfWeek.millisecondsSinceEpoch.toDouble()
        };
      }

      if (transaction.type == TransactionType.income) {
        weeklyData[weekKey]!['income'] =
            weeklyData[weekKey]!['income']! + transaction.amount;
      } else {
        weeklyData[weekKey]!['outcome'] =
            weeklyData[weekKey]!['outcome']! + transaction.amount;
      }
    }

    final sortedWeeks = weeklyData.entries.toList()
      ..sort((a, b) => a.value['date']!.compareTo(b.value['date']!));

    final dateLabels = sortedWeeks.map((e) => e.key).toList();
    final List<BarChartGroupData> groups = [];
    double maxY = 0;

    for (int i = 0; i < sortedWeeks.length; i++) {
      final income = sortedWeeks[i].value['income']!;
      final outcome = sortedWeeks[i].value['outcome']!;

      maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: outcome,
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
    };
  }

  // Dados por mês (para filtro "Ano")
  Map<String, dynamic> _calculateMonthlyData() {
    final Map<int, Map<String, double>> monthlyData = {};

    for (var transaction in transactions) {
      final month = transaction.date.month;

      if (!monthlyData.containsKey(month)) {
        monthlyData[month] = {'income': 0.0, 'outcome': 0.0};
      }

      if (transaction.type == TransactionType.income) {
        monthlyData[month]!['income'] =
            monthlyData[month]!['income']! + transaction.amount;
      } else {
        monthlyData[month]!['outcome'] =
            monthlyData[month]!['outcome']! + transaction.amount;
      }
    }

    final monthNames = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    final sortedMonths = monthlyData.keys.toList()..sort();
    final dateLabels = sortedMonths.map((m) => monthNames[m - 1]).toList();
    final List<BarChartGroupData> groups = [];
    double maxY = 0;

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final income = monthlyData[month]!['income']!;
      final outcome = monthlyData[month]!['outcome']!;

      maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: outcome,
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
    };
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Entradas', Colors.green),
        const SizedBox(width: 24),
        _buildLegendItem('Saídas', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
