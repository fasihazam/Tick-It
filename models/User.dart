class User {
  final int id;
  final int role;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String token;

  const User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'token': token,
    };
  }
}