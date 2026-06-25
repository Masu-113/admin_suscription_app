import 'package:flutter/material.dart';
import '../data/repositories/category_repository.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final repo = CategoryRepository();
  final controller = TextEditingController();

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    categories = await repo.getCategories();
    setState(() {});
  }

  Future<void> add() async {
    await repo.insertCategory(Category(name: controller.text));

    controller.clear();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),

      body: Column(
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final c = categories[index];

                return ListTile(title: Text(c.name));
              },
            ),
          ),
        ],
      ),
    );
  }
}
