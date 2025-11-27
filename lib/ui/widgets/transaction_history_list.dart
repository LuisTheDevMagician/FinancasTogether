import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../screens/transaction_form_screen.dart';

class TransactionHistoryList extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final String activeUserId;
  final bool isSharedMode;

  const TransactionHistoryList({
    super.key,
    required this.transactions,
    required this.categories,
    required this.activeUserId,
    this.isSharedMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    // Agrupar transações por data
    final groupedTransactions = _groupByDate(transactions);
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Mais recente primeiro

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${transactions.length} transações',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dayTransactions = groupedTransactions[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _formatDateHeader(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                ...dayTransactions.map((transaction) {
                  return _buildTransactionItem(context, transaction);
                }),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey),
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

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final category = categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => Category(
        id: '',
        name: 'Sem Categoria',
        type: CategoryType.both,
        colorHex: '#999999',
        createdAt: DateTime.now(),
      ),
    );

    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
    final categoryColor = _parseColor(category.colorHex);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryColor.withOpacity(0.2),
          child: Icon(
            _getCategoryIcon(category.name),
            color: categoryColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              'R\$ ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  transaction.note!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                DateFormat('HH:mm').format(transaction.date),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Implementar edição de transação
          _showTransactionDetails(context, transaction, category);
        },
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupByDate(
      List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Hoje';
    } else if (date == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM/yyyy (EEEE)', 'pt_BR').format(date);
    }
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('salário') || name.contains('trabalho')) {
      return Icons.work;
    } else if (name.contains('alimentação') || name.contains('comida')) {
      return Icons.restaurant;
    } else if (name.contains('transporte')) {
      return Icons.directions_car;
    } else if (name.contains('saúde')) {
      return Icons.local_hospital;
    } else if (name.contains('educação')) {
      return Icons.school;
    } else if (name.contains('lazer') || name.contains('entretenimento')) {
      return Icons.movie;
    } else if (name.contains('moradia') || name.contains('casa')) {
      return Icons.home;
    } else if (name.contains('investimento')) {
      return Icons.trending_up;
    }
    return Icons.category;
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaction transaction,
    Category category,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        final isIncome = transaction.type == TransactionType.income;
        final color = isIncome ? Colors.green : Colors.red;

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalhes da Transação',
                    style: Theme.of(modalContext).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Categoria', category.name),
              _buildDetailRow('Tipo', isIncome ? 'Entrada' : 'Saída'),
              _buildDetailRow(
                'Valor',
                'R\$ ${transaction.amount.toStringAsFixed(2)}',
                valueColor: color,
              ),
              _buildDetailRow(
                'Data',
                DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
              ),
              if (transaction.note != null && transaction.note!.isNotEmpty)
                _buildDetailRow('Observação', transaction.note!),
              const SizedBox(height: 24),
              if (!isSharedMode)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionFormScreen(
                                type: transaction.type,
                                activeUserId: activeUserId,
                                transaction: transaction,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Primeiro fechar o modal
                          Navigator.pop(modalContext);
                          // Então confirmar e excluir
                          await _confirmDelete(context, transaction, category);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Excluir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Transaction transaction,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Transação'),
        content: Text(
          'Deseja realmente excluir esta transação de ${category.name} no valor de R\$ ${transaction.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;

      // Disparar evento de exclusão
      context.read<TransactionBloc>().add(DeleteTransaction(transaction.id));

      // Mostrar feedback
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transação excluída com sucesso'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
