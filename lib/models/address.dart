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

  factory Address.fromJson(Map<String, dynamic> json, {String? id}) {
    return Address(
      id: id ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  factory Address.fromFirestore(Map<String, dynamic> json, String id) {
    return Address.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}
