import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/expense_repository.dart';
import '../../core/money.dart';

import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';

class ExpenseFilter {
  final int? startDate;
  final int? endDate;

  ExpenseFilter({this.startDate, this.endDate});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseFilter &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

final expenseListProvider = StreamProvider.family<List<Expense>, ExpenseFilter>(
  (ref, filter) {
    return ref
        .watch(expenseRepositoryProvider)
        .watchExpenses(startDate: filter.startDate, endDate: filter.endDate);
  },
);

class ExpenseView extends ConsumerStatefulWidget {
  const ExpenseView({super.key});

  @override
  ConsumerState<ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends ConsumerState<ExpenseView> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(
      expenseListProvider(
        ExpenseFilter(
          startDate: _startDate?.millisecondsSinceEpoch,
          endDate: _endDate?.millisecondsSinceEpoch,
        ),
      ),
    );

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _startDate == null
                              ? 'Start Date'
                              : DateFormat.yMd().format(_startDate!),
                        ),
                        onPressed: () async {
                          final dt = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (dt != null) setState(() => _startDate = dt);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _endDate == null
                              ? 'End Date'
                              : DateFormat.yMd().format(_endDate!),
                        ),
                        onPressed: () async {
                          final dt = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (dt != null) setState(() => _endDate = dt);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _startDate = null;
                        _endDate = null;
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: expensesAsync.when(
                  data: (expenses) {
                    if (expenses.isEmpty)
                      return const Center(child: Text('No expenses found.'));
                    return ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final e = expenses[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.receipt),
                          ),
                          title: Text(e.category),
                          subtitle: Text(
                            '${DateFormat.yMd().add_Hm().format(DateTime.fromMillisecondsSinceEpoch(e.occurredAt))}\n${e.note ?? ''}',
                          ),
                          trailing: Text(
                            Money(e.amountCents).format(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          isThreeLine: e.note != null && e.note!.isNotEmpty,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    String category = 'Supplies';
    String amountStr = '';
    String note = '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items:
                        [
                              'Supplies',
                              'Rent',
                              'Utilities',
                              'Payroll',
                              'Marketing',
                              'Other',
                            ]
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => category = v!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => amountStr = v,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                    ),
                    onChanged: (v) => note = v,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountStr);
                    if (amount != null && amount > 0) {
                      ref
                          .read(expenseRepositoryProvider)
                          .addExpense(
                            category: category,
                            amountCents: (amount * 100).round(),
                            note: note.isEmpty ? null : note,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
