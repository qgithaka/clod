import 'package:flutter/material.dart';
import 'expense_view.dart';
import 'shrinkage_view.dart';

class BackOfficeView extends StatelessWidget {
  const BackOfficeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Back-Office Operations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Purchase Orders'),
              Tab(text: 'Expenses'),
              Tab(text: 'Stock Issues'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Purchase Orders coming soon...')),
            ExpenseView(),
            ShrinkageView(),
          ],
        ),
      ),
    );
  }
}
