class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? address;
  final String? imageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    this.imageUrl,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      phone: map['phone']?.toString(),
      address: map['address']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    };

    // Solo incluir imageUrl si no es null
    if (imageUrl != null) {
      map['imageUrl'] = imageUrl;
    }

    return map;
  }
}
