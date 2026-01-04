// class ShoppingItem {
//   int? id;
//   int listId; // links item to a specific shopping list
//   String name;
//   bool isDone;

//   ShoppingItem({
//     this.id,
//     required this.listId,
//     required this.name,
//     this.isDone = false,
//   });

//   // Convert a ShoppingItem into a Map. The keys must correspond to the database columns
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'listId': listId,
//       'name': name,
//       'isDone': isDone ? 1 : 0, // store bool as integer for SQLite
//     };
//   }

//   // Convert a Map from the database into a ShoppingItem object
//   factory ShoppingItem.fromMap(Map<String, dynamic> map) {
//     return ShoppingItem(
//       id: map['id'],
//       listId: map['listId'],
//       name: map['name'],
//       isDone: map['isDone'] == 1, // convert integer back to bool
//     );
//   }
// }
class ShoppingItem {
  int? id;
  int listId; // links item to a specific shopping list
  String name;
  bool isDone;

  // 🆕 Budget-related fields
  double price;
  int quantity;

  ShoppingItem({
    this.id,
    required this.listId,
    required this.name,
    this.isDone = false,
    this.price = 0.0,
    this.quantity = 1,
  });

  // Convert a ShoppingItem into a Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listId': listId,
      'name': name,
      'isDone': isDone ? 1 : 0, // store bool as integer
      'price': price,
      'quantity': quantity,
    };
  }

  // Convert a Map from the database into a ShoppingItem object
  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      listId: map['listId'],
      name: map['name'],
      isDone: map['isDone'] == 1,
      price: map['price'] != null ? map['price'] as double : 0.0,
      quantity: map['quantity'] != null ? map['quantity'] as int : 1,
    );
  }
}
