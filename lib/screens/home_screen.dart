import 'package:admin_suscription_app/screens/category_screen.dart';
import 'package:admin_suscription_app/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import 'add_subscription_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Suscripciones")),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.subscriptions.isEmpty
          ? const Center(child: Text("No hay suscripciones"))
          : ListView.builder(
              itemCount: provider.subscriptions.length,

              itemBuilder: (context, index) {
                final sub = provider.subscriptions[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(
                    title: Text(sub.serviceName),

                    subtitle: Text(
                      "Renewal: ${sub.renewalDate.toLocal().toString().split(' ')[0]}",
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text("\$${sub.cost}"),

                            Text(
                              sub.status,

                              style: TextStyle(
                                color: sub.status == "Active"
                                    ? Colors.green
                                    : Colors.red,

                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),

                          onPressed: () async {
                            await Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    AddSubscriptionScreen(subscription: sub),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () {
                            if (sub.id != null) {
                              context
                                  .read<SubscriptionProvider>()
                                  .deleteSubscription(sub.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "add_sub",
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddSubscriptionScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "categories",
            backgroundColor: Colors.orange,
            child: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "payments",
            backgroundColor: Colors.green,
            child: const Icon(Icons.payment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
