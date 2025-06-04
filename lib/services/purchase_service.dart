import 'package:mongo_dart/mongo_dart.dart';
import '../models/purchase.dart';
import '../config/database.dart';

class PurchaseService {
  static DbCollection get _purchases => DatabaseConfig.purchases;

  static Future<List<Purchase>> getPurchasesByUser(String userId) async {
    final purchases = await _purchases.find({'userId': userId}).toList();
    return purchases
        .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> addPurchase(Purchase purchase) async {
    await _purchases.insertOne(purchase.toJson());
  }
}
