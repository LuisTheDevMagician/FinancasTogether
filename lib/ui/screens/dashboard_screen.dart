import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../blocs/filter/filter_bloc.dart';
import '../../blocs/filter/filter_state.dart';
import '../../blocs/filter/filter_event.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/period_bar_chart.dart';
import '../widgets/shared_period_bar_chart.dart';
import '../widgets/transaction_history_list.dart';

class DashboardScreen extends StatefulWidget {
  final String? activeUserId;

  const DashboardScreen({super.key, this.activeUserId});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  bool _isSharedMode = false; // false = Individual, true = Compartilhado

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    // Carregar todas as categorias (Dashboard precisa de todas)
    context.read<CategoryBloc>().add(const LoadCategories());
    // Carregar usuários (para modo compartilhado)
    context.read<UserBloc>().add(const LoadUsers());
    // Carregar transações do período
    _loadTransactions();
  }

  void _loadTransactions() {
    final filterState = context.read<FilterBloc>().state;
    final dateRange = _getDateRangeFromPeriod(filterState.period);

    context.read<TransactionBloc>().add(
          LoadTransactionsByFilter(
            fromDate: dateRange['from'],
            toDate: dateRange['to'],
            userId: _isSharedMode
                ? null
                : widget.activeUserId, // null = todos os usuários
          ),
        );
  }

  Map<String, DateTime> _getDateRangeFromPeriod(Period period) {
    final now = DateTime.now();
    DateTime from;
    DateTime to;

    switch (period) {
      case Period.day:
        // Hoje: 00:00:00 até 23:59:59
        from = DateTime(now.year, now.month, now.day);
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case Period.week:
        // Semana atual: de domingo até sábado
        final weekday = now.weekday % 7; // 0=Sunday, 1=Monday, ..., 6=Saturday
        from = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday)); // Voltar para domingo
        to = from.add(const Duration(
            days: 6, hours: 23, minutes: 59, seconds: 59)); // Até sábado
        break;
      case Period.month:
        // Mês atual completo
        from = DateTime(now.year, now.month, 1);
        to = DateTime(
            now.year, now.month + 1, 0, 23, 59, 59); // Último dia do mês
        break;
      case Period.year:
        // Ano atual completo
        from = DateTime(now.year, 1, 1);
        to = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }

    return {'from': from, 'to': to};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // Importar a função do main.dart
              final appState = appKey.currentState;
              if (appState != null) {
                appState.toggleTheme();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de período
          _buildPeriodFilter(context),

          const Divider(height: 1),

          // Conteúdo
          Expanded(
            child: BlocListener<FilterBloc, FilterState>(
              listener: (context, state) {
                loadData();
              },
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, transactionState) {
                  if (transactionState is TransactionsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (transactionState is TransactionsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(transactionState.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: loadData,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  final transactions = transactionState is TransactionsLoaded
                      ? transactionState.transactions
                      : <Transaction>[];

                  return BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, categoryState) {
                      final categories = categoryState is CategoriesLoaded
                          ? categoryState.categories
                          : <Category>[];

                      return BlocBuilder<UserBloc, UserState>(
                        builder: (context, userState) {
                          final users = userState is UsersLoaded
                              ? userState.users
                              : <User>[];

                          return RefreshIndicator(
                            onRefresh: () async {
                              loadData();
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Gráfico de Pizza (apenas modo individual)
                                  if (!_isSharedMode)
                                    CategoryPieChart(
                                      transactions: transactions,
                                      categories: categories,
                                    ),

                                  if (!_isSharedMode)
                                    const SizedBox(height: 32),

                                  // Gráfico de Barras
                                  if (_isSharedMode && users.length >= 2)
                                    SharedPeriodBarChart(
                                      transactions: transactions,
                                      users: users,
                                      periodLabel: context
                                          .read<FilterBloc>()
                                          .state
                                          .period
                                          .label,
                                    )
                                  else if (!_isSharedMode)
                                    PeriodBarChart(
                                      transactions: transactions,
                                      periodLabel: context
                                          .read<FilterBloc>()
                                          .state
                                          .period
                                          .label,
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Modo compartilhado requer pelo menos 2 usuários cadastrados',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 32),

                                  // Histórico de Transações
                                  TransactionHistoryList(
                                    transactions: transactions,
                                    categories: categories,
                                    activeUserId: widget.activeUserId ?? '',
                                    isSharedMode: _isSharedMode,
                                  ),

                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          final transactions = state is TransactionsLoaded
              ? state.transactions
              : <Transaction>[];

          if (transactions.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Botão Individual/Compartilhado
              FloatingActionButton.extended(
                heroTag: 'mode_btn',
                onPressed: () {
                  setState(() {
                    _isSharedMode = !_isSharedMode;
                  });
                  loadData();
                },
                icon: Icon(_isSharedMode ? Icons.people : Icons.person),
                label: Text(_isSharedMode ? 'Compartilhado' : 'Individual'),
                backgroundColor: _isSharedMode ? Colors.purple : Colors.blue,
              ),
              const SizedBox(height: 8),
              // Botão Exportar (menor)
              FloatingActionButton(
                heroTag: 'export_btn',
                mini: true,
                onPressed: () {
                  _showExportDialog(context, transactions);
                },
                child: const Icon(Icons.download),
                tooltip: 'Exportar',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodFilter(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Period.values.map((period) {
              final isSelected = state.period == period;
              return _buildPeriodChip(
                context: context,
                period: period,
                isSelected: isSelected,
                onTap: () {
                  context.read<FilterBloc>().add(SetPeriod(period));
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPeriodChip({
    required BuildContext context,
    required Period period,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        child: Text(
          period.label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, List<Transaction> transactions) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar Transações'),
          content: Text(
            'Exportar ${transactions.length} transações do período selecionado em PDF?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _exportPDF(transactions);
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF'),
            ),
          ],
        );
      },
    );
  }

  void _exportPDF(List<Transaction> transactions) {
    // TODO: Implementar exportação PDF usando ExportHelpers
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportação PDF em desenvolvimento'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
