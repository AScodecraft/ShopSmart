class User {
  int? id;
  String name; // ✅ Added
  String email;
  String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // Convert User object to Map (for database)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'password': password};
  }

  // Convert Map to User object (from database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '', // ✅ Safe null handling
      email: map['email'],
      password: map['password'],
    );
  }
}
