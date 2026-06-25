import 'package:flutter/material.dart';
import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final repo = PaymentMethodRepository();

  final typeController = TextEditingController();
  final detailController = TextEditingController();

  List<PaymentMethod> methods = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    methods = await repo.getPaymentMethods();
    setState(() {});
  }

  Future<void> add() async {
    await repo.insertPaymentMethod(
      PaymentMethod(type: typeController.text, details: detailController.text),
    );

    typeController.clear();
    detailController.clear();

    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: "Type (Card, PayPal)",
                  ),
                ),

                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(labelText: "Details"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(onPressed: add, child: const Text("Add")),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final m = methods[index];

                return ListTile(
                  title: Text(m.type),
                  subtitle: Text(m.details ?? ""),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
