import 'package:admin_suscription_app/models/billing_cycle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription_full.dart';
import '../models/payment_history.dart';
import '../providers/payment_history_provider.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final SubscriptionFull data;

  const SubscriptionDetailScreen({super.key, required this.data});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PaymentHistoryProvider>().loadPayments();
    });
  }

  DateTime _calculateCoveredUntil(List<PaymentHistory> payments) {
    final subscription = widget.data.subscription;

    DateTime baseDate;

    if (payments.isEmpty) {
      baseDate = subscription.startDate;
    } else {
      final sortedPayments = List<PaymentHistory>.from(payments);

      sortedPayments.sort((a, b) => b.coveredUntil.compareTo(a.coveredUntil));

      baseDate = sortedPayments.first.coveredUntil;
    }

    if (subscription.billingCycle == BillingCycle.monthly) {
      return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
    } else {
      return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
    }
  }

  Future<void> _addPayment(List<PaymentHistory> payments) async {
    final subscription = widget.data.subscription;

    if (subscription.id == null) {
      return;
    }

    final today = DateTime.now();

    final hasActivePayment = payments.any((p) {
      return today.isBefore(p.coveredUntil.add(const Duration(days: 1)));
    });

    if (hasActivePayment) {
      final confirm = await showDialog<bool>(
        context: context,

        builder: (_) {
          return AlertDialog(
            title: const Text("Pago adelantado"),

            content: const Text(
              "Esta suscripción ya tiene un periodo cubierto.\n\n¿Deseas registrar un pago adelantado?",
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },

                child: const Text("Cancelar"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },

                child: const Text("Continuar"),
              ),
            ],
          );
        },
      );

      if (confirm != true) {
        return;
      }
    }

    final coveredUntil = _calculateCoveredUntil(payments);

    final payment = PaymentHistory(
      paymentDate: DateTime.now(),

      amount: subscription.cost,

      subscriptionId: subscription.id!,

      coveredUntil: coveredUntil,
    );

    await context.read<PaymentHistoryProvider>().addPayment(payment);
  }

  @override
  Widget build(BuildContext context) {
    final subscription = widget.data.subscription;

    return Scaffold(
      appBar: AppBar(title: Text(subscription.serviceName)),

      body: Consumer<PaymentHistoryProvider>(
        builder: (context, provider, _) {
          final payments =
              provider.payments
                  .where((p) => p.subscriptionId == subscription.id)
                  .toList()
                ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

          final totalPaid = payments.fold<double>(
            0,
            (sum, p) => sum + p.amount,
          );

          final lastPayment = payments.isNotEmpty ? payments.first : null;

          final cycleText = subscription.billingCycle == BillingCycle.monthly
              ? "mes"
              : "año";

          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  subscription.serviceName,

                  style: const TextStyle(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("\$${subscription.cost} / $cycleText"),

                Text("Categoría: ${widget.data.categoryName}"),

                Text("Método: ${widget.data.paymentMethodName}"),

                const SizedBox(height: 12),

                Text("Total pagado: \$${totalPaid.toStringAsFixed(2)}"),

                Text(
                  "Último pago: ${lastPayment != null ? lastPayment.paymentDate.toString().substring(0, 10) : "N/A"}",
                ),

                const Divider(height: 30),

                const Text(
                  "Historial de pagos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                Expanded(
                  child: payments.isEmpty
                      ? const Center(child: Text("No hay pagos aún"))
                      : ListView.builder(
                          itemCount: payments.length,

                          itemBuilder: (context, index) {
                            final p = payments[index];

                            return ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),

                              title: Text("\$${p.amount}"),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Pago: ${p.paymentDate.toString().substring(0, 10)}",
                                  ),

                                  Text(
                                    "Cubre hasta: ${p.coveredUntil.toString().substring(0, 10)}",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),

                    label: const Text("Registrar pago"),

                    onPressed: () => _addPayment(payments),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
