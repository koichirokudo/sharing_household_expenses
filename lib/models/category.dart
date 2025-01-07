import 'package:sharing_household_expenses/models/sub_category.dart';

class Category {
  final int id;
  final String? groupId;
  final String type;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    this.groupId,
    required this.type,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.subCategories,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      groupId: map['group_id'],
      type: map['type'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      subCategories: (map['sub_categories'] as List)
          .map((subMap) => SubCategory.fromMap(subMap))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'type': type,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sub_categories': subCategories.map((sub) => sub.toMap()).toList(),
    };
  }
}
