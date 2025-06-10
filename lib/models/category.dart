class Category {
  final String id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json, {String? id}) =>
      Category(
        id: id ?? json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
      );

  factory Category.fromFirestore(Map<String, dynamic> json, String id) {
    return Category.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  Map<String, dynamic> toFirestore() => toJson();
}
