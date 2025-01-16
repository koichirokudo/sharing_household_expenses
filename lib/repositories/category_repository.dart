import 'package:sharing_household_expenses/utils/constants.dart';

import '../models/category.dart';

class CategoryRepository {
  Future<List<Category>> fetchCategories() async {
    final response =
        await supabase.from('categories').select().order('id', ascending: true);
    final categories =
        (response as List).map((json) => Category.fromMap(json)).toList();

    return categories;
  }
}
