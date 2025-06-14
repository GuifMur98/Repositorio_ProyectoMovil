import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address.dart';

class AddressService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Obtiene todas las direcciones del usuario autenticado
  static Future<List<Address>> getAddresses() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .get();
    return snapshot.docs
        .map((doc) => Address.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Crea una nueva dirección para el usuario autenticado
  static Future<Address> addAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .doc();
    final addressData = address.copyWith(id: ref.id, userId: user.uid).toJson();
    await ref.set(addressData);
    return Address.fromFirestore(addressData, ref.id);
  }

  /// Elimina una dirección por su id
  static Future<void> deleteAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  /// Actualiza una dirección existente para el usuario autenticado
  static Future<void> updateAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .doc(address.id)
        .set(address.copyWith(userId: user.uid).toJson());
  }
}

extension AddressCopyWith on Address {
  Address copyWith({
    String? id,
    String? userId,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
    );
  }
}
