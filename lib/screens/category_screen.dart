import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final controller = TextEditingController();

  Future<void> add() async {
    if (controller.text.trim().isEmpty) {
      return;
    }

    await context.read<CategoryProvider>().addCategory(
      Category(name: controller.text.trim()),
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

              Expanded(
                child: ListView.builder(
                  itemCount: provider.categories.length,

                  itemBuilder: (context, index) {
                    final c = provider.categories[index];

                    return ListTile(title: Text(c.name));
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
