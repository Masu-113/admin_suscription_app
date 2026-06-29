import 'package:admin_suscription_app/models/billing_cycle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription_full.dart';
import '../models/payment_history.dart';
import '../providers/payment_history_provider.dart';

import '../core/subscription_status.dart';

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

  DateTime _getLastCoveredUntil(List<PaymentHistory> payments) {
    final subscription = widget.data.subscription;

    if (payments.isEmpty) {
      return subscription.startDate;
    }

    final last = payments.reduce(
      (a, b) => a.coveredUntil.isAfter(b.coveredUntil) ? a : b,
    );

    return last.coveredUntil;
  }

  DateTime _calculateNextCoveredUntil(List<PaymentHistory> payments) {
    final subscription = widget.data.subscription;

    final base = _getLastCoveredUntil(payments);

    if (subscription.billingCycle == BillingCycle.monthly) {
      return DateTime(base.year, base.month + 1, base.day);
    } else {
      return DateTime(base.year + 1, base.month, base.day);
    }
  }

  Future<void> _addPayment(List<PaymentHistory> payments) async {
    final subscription = widget.data.subscription;

    if (subscription.id == null) {
      return;
    }

    final now = DateTime.now();

    final lastCovered = _getLastCoveredUntil(payments);

    final status = SubscriptionStatusHelper.getStatus(lastCovered);

    if (status != SubscriptionStatus.expired) {
      final confirm = await showDialog<bool>(
        context: context,

        builder: (_) {
          return AlertDialog(
            title: const Text("Pago adelantado"),

            content: const Text(
              "Esta suscripción todavía está cubierta.\n\n¿Deseas extender el periodo?",
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),

                child: const Text("Cancelar"),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context, true),

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

    final payment = PaymentHistory(
      paymentDate: now,

      amount: subscription.cost,

      subscriptionId: subscription.id!,

      coveredUntil: _calculateNextCoveredUntil(payments),
    );

    final success = await context.read<PaymentHistoryProvider>().addPayment(
      payment,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo registrar el pago.")),
      );
    }
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

          final lastCovered = _getLastCoveredUntil(payments);

          final status = SubscriptionStatusHelper.getStatus(lastCovered);

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

                Text("Estado: ${SubscriptionStatusHelper.getText(status)}"),

                Text("Total pagado: \$${totalPaid.toStringAsFixed(2)}"),

                Text(
                  "Activo hasta: ${lastCovered.toString().substring(0, 10)}",
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
