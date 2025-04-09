class Address {
  final String label;
  final String address;
  final bool isPrimary;

  Address({required this.label, required this.address, this.isPrimary = false});

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      label: map['label'],
      address: map['address'],
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'label': label, 'address': address, 'isPrimary': isPrimary};
  }
}

class User {
  final int id;
  String name;
  String email;
  String password;
  String phone;
  String profileImage;
  List<Address> addresses;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.profileImage,
    required this.addresses,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      profileImage: map['profileImage'],
      addresses:
          (map['addresses'] as List)
              .map((addr) => Address.fromMap(addr))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'profileImage': profileImage,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
    };
  }
}
