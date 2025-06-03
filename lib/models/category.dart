class Category {
  final String id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'description': description,
      };
}
