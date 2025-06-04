class Address {
  final String id;
  final String userId;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  Address({
    required this.id,
    required this.userId,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] != null
          ? json['_id'].toString()
          : '', // Convierte ObjectId a String
      userId: json['userId'] != null ? json['userId'].toString() : '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'userId': userId,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
    // Solo incluir _id si es válido (para update, no para insert)
    if (id != null && id.isNotEmpty) {
      data['_id'] = id;
    }
    return data;
  }
}
