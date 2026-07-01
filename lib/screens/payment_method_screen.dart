import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payment_method.dart';
import '../providers/payment_method_provider.dart';
import '../providers/user_provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final typeController = TextEditingController();

  final detailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = context.read<UserProvider>().currentUser;

      if (user != null) {
        context.read<PaymentMethodProvider>().loadUserMethods(user.id!);
      }
    });
  }

  Future<void> add() async {
    if (typeController.text.trim().isEmpty) {
      return;
    }

    final user = context.read<UserProvider>().currentUser;

    if (user == null) {
      return;
    }

    await context.read<PaymentMethodProvider>().addMethod(
      PaymentMethod(
        type: typeController.text.trim(),

        details: detailController.text.trim(),

        userId: user.id,
      ),
    );

    typeController.clear();

    detailController.clear();
  }

  @override
  void dispose() {
    typeController.dispose();

    detailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods")),

      body: Consumer<PaymentMethodProvider>(
        builder: (context, provider, _) {
          return Column(
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
                  itemCount: provider.methods.length,

                  itemBuilder: (context, index) {
                    final m = provider.methods[index];

                    return ListTile(
                      title: Text(m.type),

                      subtitle: Text(m.details ?? ""),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
