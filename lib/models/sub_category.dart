class SubCategory {
  final int id;
  final int? parentId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.parentId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'],
      parentId: map['category_id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': parentId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
