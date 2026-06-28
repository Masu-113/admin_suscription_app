import 'package:flutter/material.dart';

import '../data/repositories/category_repository.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<Category> categories = [];

  bool isLoading = false;

  Future<void> loadCategories() async {
    try {
      isLoading = true;
      notifyListeners();

      categories = await _repo.getCategories();
    } catch (e) {
      debugPrint("Error loading categories: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    await _repo.insertCategory(category);

    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repo.updateCategory(category);

    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _repo.deleteCategory(id);

    await loadCategories();
  }
}
