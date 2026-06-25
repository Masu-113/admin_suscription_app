import 'package:flutter/material.dart';
import '../data/repositories/category_repository.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final _repo = CategoryRepository();

  List<Category> categories = [];

  Future<void> loadCategories() async {
    categories = await _repo.getCategories();
    notifyListeners();
  }
}
