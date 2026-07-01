import 'package:flutter/material.dart';

import '../data/repositories/category_repository.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<Category> categories = [];

  bool isLoading = false;

  int? currentUserId;

  // TODAS LAS CATEGORIAS
  // futuro uso admin

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

  // CATEGORIAS DEL USUARIO

  Future<void> loadUserCategories(int userId) async {
    try {
      currentUserId = userId;

      isLoading = true;

      notifyListeners();

      categories = await _repo.getCategoriesByUser(userId);
    } catch (e) {
      debugPrint("Error loading user categories: $e");
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // ADD

  Future<void> addCategory(Category category) async {
    await _repo.insertCategory(category);

    if (currentUserId != null) {
      await loadUserCategories(currentUserId!);
    } else {
      await loadCategories();
    }
  }

  // UPDATE

  Future<void> updateCategory(Category category) async {
    await _repo.updateCategory(category);

    if (currentUserId != null) {
      await loadUserCategories(currentUserId!);
    } else {
      await loadCategories();
    }
  }

  // DELETE

  Future<void> deleteCategory(int id) async {
    await _repo.deleteCategory(id);

    if (currentUserId != null) {
      await loadUserCategories(currentUserId!);
    } else {
      await loadCategories();
    }
  }
}
