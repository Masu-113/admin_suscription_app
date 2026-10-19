import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payment_method.dart';
import '../providers/payment_method_provider.dart';
import '../core/session_manager.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final typeController = TextEditingController();
  final detailController = TextEditingController();
  PaymentMethod? editingMethod; // Para almacenar el método que se está editando

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      final user = SessionManager.instance.currentUser;
      if (user != null) {
        context.read<PaymentMethodProvider>().loadUserMethods(user.id);
      }
    });
  }

  Future<void> addOrUpdate() async {
    if (typeController.text.trim().isEmpty) {
      return;
    }

    final user = SessionManager.instance.currentUser;

    if (user == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<PaymentMethodProvider>();

    final type = typeController.text.trim();
    final details = detailController.text.trim();

    final bool ok;

    if (editingMethod != null) {
      ok = await provider.updateMethod(
        editingMethod!.copyWith(type: type, details: details),
      );
    } else {
      ok = await provider.addMethod(
        PaymentMethod(type: type, details: details, userId: user.id),
      );
    }

    if (!mounted) return;

    setState(() {
      editingMethod = null;
    });
    typeController.clear();
    detailController.clear();

    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? "Ocurrió un error")),
      );
    }
  }

  void editMethod(PaymentMethod method) {
    setState(() {
      editingMethod = method;
      typeController.text = method.type; // Prellenar el campo
      detailController.text = method.details ?? ""; // Prellenar el campo
    });
  }

  Future<void> deleteMethod(PaymentMethod method) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<PaymentMethodProvider>();

    final ok = await provider.deleteMethod(method);

    if (!mounted || ok) return;

    messenger.showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? "Ocurrió un error")),
    );
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
                    ElevatedButton(
                      onPressed: addOrUpdate,
                      child: Text(editingMethod == null ? "Add" : "Update"),
                    ),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editMethod(m), // Editar método
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Confirmar eliminación
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirmar eliminación"),
                                  content: const Text(
                                    "¿Estás seguro de que deseas eliminar este método de pago?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteMethod(m);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Eliminar"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
