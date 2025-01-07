import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sharing_household_expenses/models/category.dart';

part 'category_state.freezed.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState({
    required List<Category> incomeCategories,
    required List<Category> expenseCategories,
    required List<Category> categories,
  }) = _CategoryState;
}
