class ShoppingList {
  int? id;
  String name;
  int? userId; // 🔥 Added userId

  ShoppingList({this.id, required this.name, this.userId});

  // Convert ShoppingList to Map for database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (userId != null) 'userId': userId,
    };
  }

  // Create ShoppingList object from Map safely
  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] is int
          ? map['id'] as int
          : int.tryParse(map['id'].toString()),
      name: map['name'].toString(),
      userId: map['userId'] is int
          ? map['userId'] as int
          : int.tryParse(map['userId']?.toString() ?? ''),
    );
  }
}
