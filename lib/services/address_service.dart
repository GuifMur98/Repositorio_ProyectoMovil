import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/address.dart';

class AddressService {
  static Future<List<Address>> getAddressesByUser(String userId) async {
    final docs =
        await DatabaseConfig.addresses.find({'userId': userId}).toList();
    return docs.map((doc) => Address.fromJson(doc)).toList();
  }

  static Future<Address?> getAddressById(String id) async {
    final doc =
        await DatabaseConfig.addresses.findOne({'_id': ObjectId.parse(id)});
    return doc != null ? Address.fromJson(doc) : null;
  }

  static Future<void> addAddress(Address address) async {
    await DatabaseConfig.addresses.insert(address.toJson());
  }

  static Future<void> updateAddress(Address address) async {
    await DatabaseConfig.addresses.update(
      {'_id': ObjectId.parse(address.id)},
      address.toJson(),
    );
  }

  static Future<void> deleteAddress(String id) async {
    await DatabaseConfig.addresses.remove({'_id': ObjectId.parse(id)});
  }
}
