import 'package:flutter/material.dart';

class CategoryExpenseCard extends StatelessWidget {
  final String categoryName;
  final double amount;
  final Color color;

  const CategoryExpenseCard({
    super.key,

    required this.categoryName,

    required this.amount,

    required this.color,
  });

  String formatMoney(double value) {
    return "\$${value.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 3,

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,

          child: const Icon(Icons.category, color: Colors.white),
        ),

        title: Text(
          categoryName,

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        trailing: Text(
          formatMoney(amount),

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
