import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,

    required this.title,

    required this.value,

    required this.color,

    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 4,

      child: ListTile(
        leading: Icon(icon, color: color),

        title: Text(title),

        trailing: Text(
          value,

          style: TextStyle(
            fontSize: 20,

            fontWeight: FontWeight.bold,

            color: color,
          ),
        ),
      ),
    );
  }
}
