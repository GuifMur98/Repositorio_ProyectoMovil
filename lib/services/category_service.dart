import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/category.dart';

class CategoryService {
  static Future<List<Category>> getAllCategories() async {
    final docs = await DatabaseConfig.categories.find().toList();
    return docs.map((doc) => Category.fromJson(doc)).toList();
  }

  static Future<void> addCategory(Category category) async {
    await DatabaseConfig.categories.insert(category.toJson());
  }

  static Future<void> updateCategory(Category category) async {
    await DatabaseConfig.categories.update(
      {'_id': ObjectId.parse(category.id)},
      category.toJson(),
    );
  }

  static Future<void> deleteCategory(String id) async {
    await DatabaseConfig.categories.remove({'_id': ObjectId.parse(id)});
  }
}
