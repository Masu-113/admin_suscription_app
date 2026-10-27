import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription.dart';
import '../models/billing_cycle.dart';
import '../providers/subscription_provider.dart';
import '../providers/category_provider.dart';
import '../providers/payment_method_provider.dart';

import '../models/payment_history.dart';
import '../providers/payment_history_provider.dart';

import '../core/session_manager.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;

  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

DateTime _calculateInitialCoverage(Subscription sub) {
  return sub.billingCycle.nextDate(sub.startDate);
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final nameController = TextEditingController();
  final costController = TextEditingController();

  late bool isEditing;

  int? selectedCategoryId;
  int? selectedPaymentId;

  DateTime? selectedStartDate;

  BillingCycle selectedCycle = BillingCycle.monthly;

  @override
  void initState() {
    super.initState();

    isEditing = widget.subscription != null;

    if (isEditing) {
      final sub = widget.subscription!;

      nameController.text = sub.serviceName;
      costController.text = sub.cost.toString();

      selectedCategoryId = sub.categoryId;
      selectedPaymentId = sub.paymentMethodId;

      selectedStartDate = sub.startDate;
      selectedCycle = sub.billingCycle;
    } else {
      selectedStartDate = DateTime.now();
    }
    final userId = SessionManager.instance.userId;

    if (userId != null) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<CategoryProvider>().loadUserCategories(userId);
        context.read<PaymentMethodProvider>().loadUserMethods(userId);
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedStartDate = date;
      });
    }
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty ||
        costController.text.trim().isEmpty ||
        selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    // No permitir fechas futuras
    final today = DateTime.now();

    final startDateOnly = DateTime(
      selectedStartDate!.year,
      selectedStartDate!.month,
      selectedStartDate!.day,
    );

    final todayOnly = DateTime(today.year, today.month, today.day);

    if (startDateOnly.isAfter(todayOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La fecha de inicio no puede ser futura")),
      );

      return;
    }

    final cost = double.tryParse(costController.text);

    if (cost == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid cost")));

      return;
    }

    final currentUser = SessionManager.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No hay usuario activo")));
      return;
    }

    final subscription = Subscription(
      id: widget.subscription?.id,
      cloudId: widget.subscription?.cloudId,
      serviceName: nameController.text.trim(),
      cost: cost,
      startDate: selectedStartDate!,
      billingCycle: selectedCycle,
      status: widget.subscription?.status ?? "Active",
      isCancelled: widget.subscription?.isCancelled ?? 0,
      categoryId: selectedCategoryId,
      paymentMethodId: selectedPaymentId,
      userId: currentUser.id,
    );

    final subscriptionProvider = context.read<SubscriptionProvider>();
    final paymentProvider = context.read<PaymentHistoryProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (isEditing) {
      final ok = await subscriptionProvider.updateSubscription(subscription);
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              subscriptionProvider.errorMessage ?? "Ocurrió un error",
            ),
          ),
        );
      }
    } else {
      final id = await subscriptionProvider.addSubscription(subscription);

      if (id == null) {
        // No se guardó nada: se queda en el formulario para reintentar
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              subscriptionProvider.errorMessage ?? "Ocurrió un error",
            ),
          ),
        );
        return;
      }

      if (!mounted) return;

      final registerPayment = await showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Registrar primer pago"),

            content: Text(
              "¿Deseas registrar el primer pago de ${subscription.serviceName} por \$${subscription.cost}?",
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },

                child: const Text("No"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },

                child: const Text("Sí"),
              ),
            ],
          );
        },
      );

      if (registerPayment == true) {
        final ok = await paymentProvider.addPayment(
          PaymentHistory(
            paymentDate: subscription.startDate,
            amount: subscription.cost,
            subscriptionId: id,
            coveredUntil: _calculateInitialCoverage(subscription),
          ),
        );

        if (!mounted) return;

        if (!ok) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                paymentProvider.errorMessage ?? "No se pudo registrar el pago",
              ),
            ),
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text("Pago registrado correctamente")),
          );
          Navigator.pop(
            context,
          ); // Cerrar el formulario después de registrar el pago // Cerrar el formulario después de registrar el pago
        }
      } else {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Suscripción guardada sin registrar pago"),
          ),
        );
        Navigator.pop(
          context,
        ); // Cerrar el formulario después de guardar la suscripción
      }
      // Cerrar el formulario después de guardar la suscripción
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Subscription" : "New Subscription"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Service name"),
            ),

            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: "Cost"),
            ),

            const SizedBox(height: 15),

            // START DATE
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Start date: ${selectedStartDate?.toLocal().toString().split(' ')[0] ?? ''}",
                  ),
                ),
                TextButton(onPressed: _pickDate, child: const Text("Select")),
              ],
            ),

            const SizedBox(height: 10),

            // BILLING CYCLE
            DropdownButtonFormField<BillingCycle>(
              initialValue: selectedCycle,
              items: BillingCycle.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c == BillingCycle.monthly ? "Monthly" : "Yearly"),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCycle = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: "Billing cycle"),
            ),

            const SizedBox(height: 15),

            Consumer<CategoryProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,
                  items: provider.categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCategoryId = value);
                  },
                  decoration: const InputDecoration(labelText: "Category"),
                );
              },
            ),

            const SizedBox(height: 10),

            Consumer<PaymentMethodProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<int>(
                  initialValue: selectedPaymentId,
                  items: provider.methods.map((m) {
                    return DropdownMenuItem(value: m.id, child: Text(m.type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedPaymentId = value);
                  },
                  decoration: const InputDecoration(
                    labelText: "Payment Method",
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: save,
                child: Text(isEditing ? "Update" : "Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
