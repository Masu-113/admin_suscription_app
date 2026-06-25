import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/subscription.dart';
import '../data/repositories/subscription_repository.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final nameController = TextEditingController();

  final priceController = TextEditingController();

  final repo = SubscriptionRepository();

  void save() async {
    final subscription = Subscription(
      id: const Uuid().v4(),

      serviceName: nameController.text,

      price: double.parse(priceController.text),

      renewalDate: DateTime.now(),

      status: "Activa",
    );

    await repo.insertSubscription(subscription);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Suscripción")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,

              decoration: const InputDecoration(labelText: "Servicio"),
            ),

            TextField(
              controller: priceController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "Costo"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: save, child: const Text("Guardar")),
          ],
        ),
      ),
    );
  }
}
