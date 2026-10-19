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

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay un usuario autenticado")),
      );
      return;
    }

    if (editingCategory != null) {
      await context.read<CategoryProvider>().updateCategory(
        editingCategory!.copyWith(name: name),
      );

      if (!mounted) return;

      setState(() {
        editingCategory = null;
      });
    } else {
      // Agregar nueva categoría
      await context.read<CategoryProvider>().addCategory(
        Category(name: name, userId: user.id),
      );
    }

    controller.clear();
  }

  void editCategory(Category category) {
    setState(() {
      editingCategory = category;
      controller.text = category.name; // Prellenar el TextField
    });
  }

  Future<void> deleteCategory(Category category) async {
    await context.read<CategoryProvider>().deleteCategory(category);
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
