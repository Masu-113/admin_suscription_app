import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/payment_history_provider.dart';
import '../core/subscription_status.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String formatMoney(double value) {
    return "\$${value.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final paymentProvider = context.watch<PaymentHistoryProvider>();
    final subscriptions = subscriptionProvider.subscriptions;

    // Inicializar contadores y gastos
    int active = 0, cancelled = 0, aboutToExpire = 0;
    double monthlyExpense = 0;
    final Map<String, double> categoryExpenses = {};

    // Calcular estadísticas de suscripciones
    for (final item in subscriptions) {
      final subscription = item.subscription;

      if (subscription.isCancelled) {
        cancelled++;
        continue;
      }

      final lastPayment = subscription.id != null
          ? paymentProvider.getLastPaymentForSubscription(subscription.id!)
          : null;

      final coveredUntil = lastPayment?.coveredUntil ?? subscription.startDate;
      final status = SubscriptionStatusHelper.getStatus(coveredUntil);

      if (status == SubscriptionStatus.aboutToExpire) {
        aboutToExpire++;
      }
      if (status == SubscriptionStatus.active) {
        active++;
      }

      // Calcular gastos mensuales y por categoría
      double categoryAmount = subscription.billingCycle.name == "monthly"
          ? subscription.cost
          : subscription.cost / 12;

      monthlyExpense += categoryAmount;
      categoryExpenses[item.categoryName] =
          (categoryExpenses[item.categoryName] ?? 0) + categoryAmount;
    }

    final yearlyExpense = monthlyExpense * 12;
    final totalCategories = categoryExpenses.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: subscriptionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Resumen"),
                  const SizedBox(height: 15),
                  _buildStatCard(
                    "Suscripciones activas",
                    active.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildStatCard(
                    "Por vencer",
                    aboutToExpire.toString(),
                    Colors.orange,
                    Icons.warning,
                  ),
                  _buildStatCard(
                    "Canceladas",
                    cancelled.toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                  _buildStatCard(
                    "Categorías",
                    totalCategories.toString(),
                    Colors.indigo,
                    Icons.category,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Gastos"),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Gasto por categoría"),
                  const SizedBox(height: 15),
                  _buildCategoryPieChart(categoryExpenses),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Detalle por categoría"),
                  const SizedBox(height: 10),
                  ..._buildCategoryDetails(categoryExpenses),
                  const SizedBox(height: 15),
                  _buildStatCard(
                    "Gasto mensual estimado",
                    formatMoney(monthlyExpense),
                    Colors.blue,
                    Icons.calendar_month,
                  ),
                  _buildStatCard(
                    "Gasto anual estimado",
                    formatMoney(yearlyExpense),
                    Colors.purple,
                    Icons.attach_money,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> categoryExpenses) {
    return SizedBox(
      height: 250,
      child: categoryExpenses.isEmpty
          ? const Center(child: Text("No hay gastos registrados"))
          : PieChart(
              PieChartData(
                sections: categoryExpenses.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    title: "${entry.key}\n${formatMoney(entry.value)}",
                    radius: 90,
                    color:
                        Colors.primaries[categoryExpenses.keys.toList().indexOf(
                              entry.key,
                            ) %
                            Colors.primaries.length],
                  );
                }).toList(),
              ),
            ),
    );
  }

  List<Widget> _buildCategoryDetails(Map<String, double> categoryExpenses) {
    return categoryExpenses.entries.map((entry) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.label),
          title: Text(entry.key),
          trailing: Text(
            formatMoney(entry.value),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
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
