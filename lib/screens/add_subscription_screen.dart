import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

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

  @override
  void initState() {
    super.initState();

    isEditing = widget.subscription != null;

    if (isEditing) {
      nameController.text = widget.subscription!.serviceName;

      costController.text = widget.subscription!.cost.toString();
    }
  }

  void save() async {
    final subscription = Subscription(
      id: widget.subscription?.id,

      serviceName: nameController.text,

      cost: double.parse(costController.text),

      renewalDate: widget.subscription?.renewalDate ?? DateTime.now(),

      status: widget.subscription?.status ?? "Active",
    );

    if (isEditing) {
      await context.read<SubscriptionProvider>().updateSubscription(
        subscription,
      );
    } else {
      await context.read<SubscriptionProvider>().addSubscription(subscription);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Subscription" : "New Subscription"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,

              decoration: const InputDecoration(labelText: "Service name"),
            ),

            TextField(
              controller: costController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "Cost"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,

              child: Text(isEditing ? "Update" : "Save"),
            ),
          ],
        ),
      ),
    );
  }
}
