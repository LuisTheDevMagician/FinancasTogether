import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import '../../models/user.dart';

class SharedPeriodBarChart extends StatelessWidget {
  final List<Transaction> transactions;
  final List<User> users;
  final String periodLabel;

  const SharedPeriodBarChart({
    super.key,
    required this.transactions,
    required this.users,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty || users.isEmpty) {
      return _buildEmptyState();
    }

    final data = _calculateData();

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data['maxY'] as double,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dateLabels = data['dateLabels'] as List<String>;
                      final userColors = data['userColors']
                          as Map<String, Map<String, dynamic>>;

                      String userName = '';
                      String type = '';

                      // Identificar usuário e tipo pela cor
                      for (var entry in userColors.entries) {
                        if (entry.value['incomeColor'] == rod.color) {
                          userName = entry.key;
                          type = 'Entrada';
                          break;
                        }
                        if (entry.value['outcomeColor'] == rod.color) {
                          userName = entry.key;
                          type = 'Saída';
                          break;
                        }
                      }

                      return BarTooltipItem(
                        '${dateLabels[groupIndex]}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '$userName - $type\n',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: _formatCurrency(rod.toY),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final dateLabels = data['dateLabels'] as List<String>;
                        if (value.toInt() >= 0 &&
                            value.toInt() < dateLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dateLabels[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatCurrency(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
        _buildLegend(data['userColors'] as Map<String, Map<String, dynamic>>),
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
    return _calculateDailyData();
  }

  // Criar mapa de cores para cada usuário
  Map<String, Map<String, dynamic>> _getUserColors() {
    final Map<String, Map<String, dynamic>> userColors = {};

    for (var user in users) {
      // Remover '#' se existir e adicionar '0xFF'
      final hexColor = user.colorHex.replaceAll('#', '');
      final baseColor = Color(int.parse('0xFF$hexColor'));

      // Cor de entrada: versão mais clara
      final incomeColor = baseColor.withOpacity(0.7);

      // Cor de saída: versão mais escura
      final outcomeColor =
          HSLColor.fromColor(baseColor).withLightness(0.3).toColor();

      userColors[user.name] = {
        'incomeColor': incomeColor,
        'outcomeColor': outcomeColor,
        'userId': user.id,
      };
    }

    return userColors;
  }

  Map<String, dynamic> _calculateDailyData() {
    final userColors = _getUserColors();
    final Map<DateTime, Map<String, Map<String, double>>> dailyData = {};

    for (var transaction in transactions) {
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = {};
        for (var userName in userColors.keys) {
          dailyData[dateKey]![userName] = {'income': 0.0, 'outcome': 0.0};
        }
      }

      // Encontrar nome do usuário
      final user = users.firstWhere((u) => u.id == transaction.userId);

      if (transaction.type == TransactionType.income) {
        dailyData[dateKey]![user.name]!['income'] =
            dailyData[dateKey]![user.name]!['income']! + transaction.amount;
      } else {
        dailyData[dateKey]![user.name]!['outcome'] =
            dailyData[dateKey]![user.name]!['outcome']! + transaction.amount;
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
      final List<BarChartRodData> rods = [];

      // Adicionar barras para cada usuário
      for (var entry in userColors.entries) {
        final userName = entry.key;
        final colors = entry.value;

        final income = dailyData[date]![userName]!['income']!;
        final outcome = dailyData[date]![userName]!['outcome']!;

        maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

        rods.add(
          BarChartRodData(
            toY: income,
            color: colors['incomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );

        rods.add(
          BarChartRodData(
            toY: outcome,
            color: colors['outcomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );
      }

      groups.add(BarChartGroupData(x: i, barRods: rods));
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
      'userColors': userColors,
    };
  }

  Map<String, dynamic> _calculateWeeklyDataForWeek() {
    final userColors = _getUserColors();
    final Map<int, Map<String, Map<String, double>>> weekData = {};

    // Inicializar dados para cada dia da semana
    for (int i = 0; i < 7; i++) {
      weekData[i] = {};
      for (var userName in userColors.keys) {
        weekData[i]![userName] = {'income': 0.0, 'outcome': 0.0};
      }
    }

    for (var transaction in transactions) {
      final weekday = transaction.date.weekday % 7;
      final user = users.firstWhere((u) => u.id == transaction.userId);

      if (transaction.type == TransactionType.income) {
        weekData[weekday]![user.name]!['income'] =
            weekData[weekday]![user.name]!['income']! + transaction.amount;
      } else {
        weekData[weekday]![user.name]!['outcome'] =
            weekData[weekday]![user.name]!['outcome']! + transaction.amount;
      }
    }

    final dateLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final List<BarChartGroupData> groups = [];
    double maxY = 0;

    for (int i = 0; i < 7; i++) {
      final List<BarChartRodData> rods = [];

      for (var entry in userColors.entries) {
        final userName = entry.key;
        final colors = entry.value;

        final income = weekData[i]![userName]!['income']!;
        final outcome = weekData[i]![userName]!['outcome']!;

        maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

        rods.add(
          BarChartRodData(
            toY: income,
            color: colors['incomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );

        rods.add(
          BarChartRodData(
            toY: outcome,
            color: colors['outcomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );
      }

      groups.add(BarChartGroupData(x: i, barRods: rods));
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
      'userColors': userColors,
    };
  }

  Map<String, dynamic> _calculateWeeklyDataForMonth() {
    final userColors = _getUserColors();
    final Map<String, Map<String, Map<String, double>>> weeklyData = {};

    for (var transaction in transactions) {
      final transactionDate = transaction.date;
      final weekday = transactionDate.weekday % 7;
      final sundayOfWeek = transactionDate.subtract(Duration(days: weekday));
      final saturdayOfWeek = sundayOfWeek.add(const Duration(days: 6));

      final weekKey =
          '${DateFormat('dd/MM').format(sundayOfWeek)}-${DateFormat('dd/MM').format(saturdayOfWeek)}';

      if (!weeklyData.containsKey(weekKey)) {
        weeklyData[weekKey] = {
          '_date': {'value': sundayOfWeek.millisecondsSinceEpoch.toDouble()}
        };
        for (var userName in userColors.keys) {
          weeklyData[weekKey]![userName] = {'income': 0.0, 'outcome': 0.0};
        }
      }

      final user = users.firstWhere((u) => u.id == transaction.userId);

      if (transaction.type == TransactionType.income) {
        weeklyData[weekKey]![user.name]!['income'] =
            weeklyData[weekKey]![user.name]!['income']! + transaction.amount;
      } else {
        weeklyData[weekKey]![user.name]!['outcome'] =
            weeklyData[weekKey]![user.name]!['outcome']! + transaction.amount;
      }
    }

    final sortedWeeks = weeklyData.entries.toList()
      ..sort((a, b) =>
          a.value['_date']!['value']!.compareTo(b.value['_date']!['value']!));

    final dateLabels = sortedWeeks.map((e) => e.key).toList();
    final List<BarChartGroupData> groups = [];
    double maxY = 0;

    for (int i = 0; i < sortedWeeks.length; i++) {
      final weekData = sortedWeeks[i].value;
      final List<BarChartRodData> rods = [];

      for (var entry in userColors.entries) {
        final userName = entry.key;
        final colors = entry.value;

        final income = weekData[userName]!['income']!;
        final outcome = weekData[userName]!['outcome']!;

        maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

        rods.add(
          BarChartRodData(
            toY: income,
            color: colors['incomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );

        rods.add(
          BarChartRodData(
            toY: outcome,
            color: colors['outcomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );
      }

      groups.add(BarChartGroupData(x: i, barRods: rods));
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
      'userColors': userColors,
    };
  }

  Map<String, dynamic> _calculateMonthlyData() {
    final userColors = _getUserColors();
    final Map<int, Map<String, Map<String, double>>> monthlyData = {};

    for (var transaction in transactions) {
      final month = transaction.date.month;

      if (!monthlyData.containsKey(month)) {
        monthlyData[month] = {};
        for (var userName in userColors.keys) {
          monthlyData[month]![userName] = {'income': 0.0, 'outcome': 0.0};
        }
      }

      final user = users.firstWhere((u) => u.id == transaction.userId);

      if (transaction.type == TransactionType.income) {
        monthlyData[month]![user.name]!['income'] =
            monthlyData[month]![user.name]!['income']! + transaction.amount;
      } else {
        monthlyData[month]![user.name]!['outcome'] =
            monthlyData[month]![user.name]!['outcome']! + transaction.amount;
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
      final List<BarChartRodData> rods = [];

      for (var entry in userColors.entries) {
        final userName = entry.key;
        final colors = entry.value;

        final income = monthlyData[month]![userName]!['income']!;
        final outcome = monthlyData[month]![userName]!['outcome']!;

        maxY = [maxY, income, outcome].reduce((a, b) => a > b ? a : b);

        rods.add(
          BarChartRodData(
            toY: income,
            color: colors['incomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );

        rods.add(
          BarChartRodData(
            toY: outcome,
            color: colors['outcomeColor'] as Color,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        );
      }

      groups.add(BarChartGroupData(x: i, barRods: rods));
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return {
      'groups': groups,
      'maxY': maxY,
      'dateLabels': dateLabels,
      'userColors': userColors,
    };
  }

  Widget _buildLegend(Map<String, Map<String, dynamic>> userColors) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: userColors.entries.map((entry) {
        final userName = entry.key;
        final colors = entry.value;

        return Column(
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors['incomeColor'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Entrada', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors['outcomeColor'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Saída', style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}
