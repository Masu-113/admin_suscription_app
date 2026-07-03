import 'package:flutter/material.dart';
import '../data/repositories/category_repository.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();
  List<Category> categories = [];
  bool isLoading = false;
  String? currentUserId;

  // LOAD USER CATEGORIES

  Future<void> loadUserCategories(String userId) async {
    try {
      isLoading = true;
      currentUserId = userId;
      notifyListeners();
      categories = await _repo.getCategoriesByUser(userId);
    } catch (e) {
      debugPrint("Error loading categories: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ADD CATEGORY

  Future<void> addCategory(Category category) async {
    try {
      isLoading = true;
      notifyListeners();
      await _repo.insertCategory(category);
      if (currentUserId != null) {
        await loadUserCategories(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error adding category: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE CATEGORY

  Future<void> updateCategory(Category category) async {
    try {
      isLoading = true;
      notifyListeners();
      await _repo.updateCategory(
        cloudId: category.cloudId ?? 0,
        name: category.name,
      );
      if (currentUserId != null) {
        await loadUserCategories(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error updating category: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // DELETE CATEGORY

  Future<void> deleteCategory(Category category) async {
    try {
      isLoading = true;
      notifyListeners();
      await _repo.deleteCategory(category);
      if (currentUserId != null) {
        await loadUserCategories(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error deleting category: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
