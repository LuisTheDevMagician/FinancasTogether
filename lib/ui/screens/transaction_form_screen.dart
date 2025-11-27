import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../models/transaction.dart' as models;
import '../../models/category.dart';
import '../../utils/constants.dart';

class TransactionFormScreen extends StatefulWidget {
  final models.TransactionType type;
  final String activeUserId;
  final models.Transaction? transaction;

  const TransactionFormScreen({
    super.key,
    required this.type,
    required this.activeUserId,
    this.transaction,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();

    // Carregar categorias apropriadas
    final categoryType = widget.type == models.TransactionType.income
        ? CategoryType.income
        : CategoryType.outcome;
    context.read<CategoryBloc>().add(LoadCategoriesByType(categoryType));

    // Se editando, preencher campos
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toStringAsFixed(2);
      _noteController.text = widget.transaction!.note ?? '';
      _selectedDate = widget.transaction!.date;
      // A categoria será definida quando as categorias forem carregadas
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == models.TransactionType.income;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? (isIncome ? 'Nova Entrada' : 'Nova Saída')
              : (isIncome ? 'Editar Entrada' : 'Editar Saída'),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            // Recarregar todas as categorias ao voltar para o Dashboard
            context.read<CategoryBloc>().add(const LoadCategories());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is TransactionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Valor
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  icon: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Valor deve ser maior que zero';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Data
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
              ),

              const SizedBox(height: 16),

              // Categoria
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoriesLoaded) {
                    // Se editando e categoria ainda não selecionada, encontrar a categoria correta
                    if (widget.transaction != null &&
                        _selectedCategory == null) {
                      _selectedCategory = state.categories.firstWhere(
                        (cat) => cat.id == widget.transaction!.categoryId,
                        orElse: () => state.categories.first,
                      );
                    }

                    if (state.categories.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                'Nenhuma categoria disponível',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Crie uma categoria primeiro',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Voltar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        icon: Icon(Icons.category),
                      ),
                      items: state.categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppConstants.hexToColor(cat.colorHex),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione uma categoria';
                        }
                        return null;
                      },
                    );
                  } else if (state is CategoriesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 16),

              // Nota
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  icon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Botão Salvar
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validar userId
      if (widget.activeUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Erro: Usuário não identificado. Selecione um usuário na tela Perfil.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final note = _noteController.text.isEmpty ? null : _noteController.text;

      if (widget.transaction == null) {
        // Criar nova
        context.read<TransactionBloc>().add(AddTransaction(
              userId: widget.activeUserId,
              categoryId: _selectedCategory!.id,
              type: widget.type,
              amount: amount,
              date: _selectedDate,
              note: note,
            ));
      } else {
        // Atualizar existente
        context.read<TransactionBloc>().add(UpdateTransaction(
              widget.transaction!.copyWith(
                categoryId: _selectedCategory!.id,
                amount: amount,
                date: _selectedDate,
                note: note,
              ),
            ));
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
