import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/category_provider.dart';
import '../providers/payment_method_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;

  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final nameController = TextEditingController();

  final costController = TextEditingController();

  late bool isEditing;

  int? selectedCategoryId;

  int? selectedPaymentId;

  @override
  void initState() {
    super.initState();

    isEditing = widget.subscription != null;

    if (isEditing) {
      nameController.text = widget.subscription!.serviceName;

      costController.text = widget.subscription!.cost.toString();

      selectedCategoryId = widget.subscription!.categoryId;

      selectedPaymentId = widget.subscription!.paymentMethodId;
    }
  }

  @override
  void dispose() {
    nameController.dispose();

    costController.dispose();

    super.dispose();
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a service name")));

      return;
    }

    if (costController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a cost")));

      return;
    }

    final cost = double.tryParse(costController.text);

    if (cost == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid cost")));

      return;
    }

    final subscription = Subscription(
      id: widget.subscription?.id,

      serviceName: nameController.text.trim(),

      cost: cost,

      renewalDate: widget.subscription?.renewalDate ?? DateTime.now(),

      status: widget.subscription?.status ?? "Active",

      categoryId: selectedCategoryId,

      paymentMethodId: selectedPaymentId,
    );

    final provider = context.read<SubscriptionProvider>();

    if (isEditing) {
      await provider.updateSubscription(subscription);
    } else {
      await provider.addSubscription(subscription);
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

            const SizedBox(height: 20),

            Consumer<CategoryProvider>(
              builder: (context, provider, _) {
                final hasValue = provider.categories.any(
                  (c) => c.id == selectedCategoryId,
                );

                return DropdownButtonFormField<int>(
                  initialValue: hasValue ? selectedCategoryId : null,

                  items: provider.categories.map((c) {
                    return DropdownMenuItem<int>(
                      value: c.id,

                      child: Text(c.name),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },

                  decoration: const InputDecoration(labelText: "Category"),
                );
              },
            ),

            const SizedBox(height: 10),

            Consumer<PaymentMethodProvider>(
              builder: (context, provider, _) {
                final hasValue = provider.methods.any(
                  (m) => m.id == selectedPaymentId,
                );

                return DropdownButtonFormField<int>(
                  initialValue: hasValue ? selectedPaymentId : null,

                  items: provider.methods.map((m) {
                    return DropdownMenuItem<int>(
                      value: m.id,

                      child: Text(m.type),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedPaymentId = value;
                    });
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
