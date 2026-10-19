import 'package:flutter/material.dart';
import '../data/repositories/category_repository.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();
  List<Category> categories = [];
  bool isLoading = false;
  String? errorMessage;
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

  Future<bool> addCategory(Category category) async {
    return _run(
      () => _repo.insertCategory(category),
      "Se guardó en este dispositivo, pero no se pudo sincronizar con la nube.",
    );
  }

  Future<bool> updateCategory(Category category) async {
    return _run(
      () => _repo.updateCategory(category),
      "Se actualizó en este dispositivo, pero no se pudo sincronizar con la nube.",
    );
  }

  Future<bool> deleteCategory(Category category) async {
    return _run(
      () => _repo.deleteCategory(category),
      "Se eliminó en este dispositivo, pero no se pudo sincronizar con la nube.",
    );
  }

  Future<bool> _run(Future<void> Function() action, String failMessage) async {
    errorMessage = null;
    var ok = true;

    try {
      isLoading = true;
      notifyListeners();
      await action();
    } catch (e) {
      ok = false;
      errorMessage = failMessage;
      debugPrint("Error en CategoryProvider: $e");
    }

    if (currentUserId != null) {
      await loadUserCategories(currentUserId!);
    } else {
      isLoading = false;
      notifyListeners();
    }

    return ok;
  }
}
