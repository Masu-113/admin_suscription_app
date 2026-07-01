import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription.dart';
import '../models/billing_cycle.dart';
import '../providers/subscription_provider.dart';
import '../providers/category_provider.dart';
import '../providers/payment_method_provider.dart';

import '../models/payment_history.dart';
import '../providers/payment_history_provider.dart';

import '../providers/user_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;

  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

DateTime _calculateInitialCoverage(Subscription sub) {
  if (sub.billingCycle == BillingCycle.monthly) {
    return DateTime(
      sub.startDate.year,
      sub.startDate.month + 1,
      sub.startDate.day,
    );
  } else {
    return DateTime(
      sub.startDate.year + 1,
      sub.startDate.month,
      sub.startDate.day,
    );
  }
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

    final currentUser = context.read<UserProvider>().currentUser;

    final subscription = Subscription(
      id: widget.subscription?.id,

      serviceName: nameController.text.trim(),

      cost: cost,

      startDate: selectedStartDate!,

      billingCycle: selectedCycle,

      status: widget.subscription?.status ?? "Active",

      categoryId: selectedCategoryId,

      paymentMethodId: selectedPaymentId,

      userId: currentUser?.id,
    );

    final subscriptionProvider = context.read<SubscriptionProvider>();

    // EDITAR
    if (isEditing) {
      await subscriptionProvider.updateSubscription(subscription);
    }
    // CREAR
    else {
      final id = await subscriptionProvider.addSubscription(subscription);

      // Preguntar primer pago
      final registerPayment = await showDialog<bool>(
        // ignore: use_build_context_synchronously
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
        // ignore: use_build_context_synchronously
        await context.read<PaymentHistoryProvider>().addPayment(
          PaymentHistory(
            paymentDate: subscription.startDate,

            amount: subscription.cost,

            subscriptionId: id,

            coveredUntil: _calculateInitialCoverage(subscription),
          ),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
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
