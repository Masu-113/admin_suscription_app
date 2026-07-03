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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = SessionManager.instance.currentUser;

      if (user != null) {
        context.read<CategoryProvider>().loadUserCategories(user.id);
      }
    });
  }

  Future<void> add() async {
    final name = controller.text.trim();

    if (name.isEmpty) return;

    final user = SessionManager.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay un usuario autenticado")),
      );
      return;
    }

    await context.read<CategoryProvider>().addCategory(
      Category(name: name, userId: user.id),
    );

    controller.clear();
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

              ElevatedButton(onPressed: add, child: const Text("Add")),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];

                    return ListTile(title: Text(category.name));
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
