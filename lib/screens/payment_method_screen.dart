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

    if (editingMethod != null) {
      // Actualizar método existente
      await context.read<PaymentMethodProvider>().updateMethod(
        PaymentMethod(
          id: editingMethod!.id, // Asegúrate de que tu modelo tenga un ID
          type: typeController.text.trim(),
          details: detailController.text.trim(),
          userId: user.id,
          cloudId: editingMethod!.cloudId, // Mantener el cloudId
        ),
      );
      setState(() {
        editingMethod = null; // Resetear después de actualizar
      });
    } else {
      // Agregar nuevo método
      await context.read<PaymentMethodProvider>().addMethod(
        PaymentMethod(
          type: typeController.text.trim(),
          details: detailController.text.trim(),
          userId: user.id,
        ),
      );
    }

    typeController.clear();
    detailController.clear();
  }

  void editMethod(PaymentMethod method) {
    setState(() {
      editingMethod = method;
      typeController.text = method.type; // Prellenar el campo
      detailController.text = method.details ?? ""; // Prellenar el campo
    });
  }

  Future<void> deleteMethod(PaymentMethod method) async {
    await context.read<PaymentMethodProvider>().deleteMethod(method);
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
