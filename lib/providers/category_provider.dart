import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../repositories/category_repository.dart';
import 'category_state.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) => CategoryNotifier(CategoryRepository()),
);

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository repository;

  CategoryNotifier(this.repository)
      : super(CategoryState(
          incomeCategories: [],
          expenseCategories: [],
          categories: [],
        ));

  Future<void> fetchCategories() async {
    try {
      final response = await repository.fetchCategories();
      state = state.copyWith(categories: response);
    } catch (e) {
      throw Exception(
          'Failed to fetch categories: ${e.runtimeType} - ${e.toString()}');
    }
  }

  void groupByType() {
    List<Category> income = [];
    List<Category> expense = [];
    for (var category in state.categories) {
      if (category.type == 'income') {
        income.add(category);
      } else if (category.type == 'expense') {
        expense.add(category);
      }
    }
    state =
        state.copyWith(incomeCategories: income, expenseCategories: expense);
  }
}
