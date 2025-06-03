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

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['_id'] ?? '',
        userId: json['userId'] ?? '',
        street: json['street'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        zipCode: json['zipCode'] ?? '',
        country: json['country'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'country': country,
      };
}
