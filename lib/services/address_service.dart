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

  static Future<Address> addAddress(Address address) async {
    // Inserta la dirección y obtiene el _id generado
    final result = await DatabaseConfig.addresses.insertOne(address.toJson());
    print('Resultado de insertOne: $result');
    if (result.isSuccess && result.id != null) {
      // Recupera el documento recién insertado usando el _id generado
      final insertedDoc =
          await DatabaseConfig.addresses.findOne({'_id': result.id});
      print('Dirección guardada: $insertedDoc');
      return Address.fromJson(insertedDoc!);
    } else {
      throw Exception('No se pudo guardar la dirección');
    }
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
