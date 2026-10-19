import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/session_manager.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final controller = TextEditingController();
  Category? editingCategory;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      final user = SessionManager.instance.currentUser;
      if (user != null) {
        context.read<CategoryProvider>().loadUserCategories(user.id);
      }
    });
  }

  Future<void> addOrUpdate() async {
    final name = controller.text.trim();

    if (name.isEmpty) return;

    final user = SessionManager.instance.currentUser;
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<CategoryProvider>();

    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text("No hay un usuario autenticado")),
      );
      return;
    }

    final bool ok;

    if (editingCategory != null) {
      ok = await provider.updateCategory(editingCategory!.copyWith(name: name));
    } else {
      ok = await provider.addCategory(Category(name: name, userId: user.id));
    }

    if (!mounted) return;

    setState(() {
      editingCategory = null;
    });
    controller.clear();

    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? "Ocurrió un error")),
      );
    }
  }

  void editCategory(Category category) {
    setState(() {
      editingCategory = category;
      controller.text = category.name; // Prellenar el TextField
    });
  }

  Future<void> deleteCategory(Category category) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<CategoryProvider>();

    final ok = await provider.deleteCategory(category);

    if (!mounted || ok) return;

    messenger.showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? "Ocurrió un error")),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "New Category"),
                ),
              ),
              ElevatedButton(
                onPressed: addOrUpdate,
                child: Text(editingCategory == null ? "Add" : "Update"),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];

                    return ListTile(
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editCategory(category),
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
                                    "¿Estás seguro de que deseas eliminar esta categoría?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteCategory(category);
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
