// // import 'package:flutter/material.dart';
// // import '../database/db_helper.dart';
// // import '../models/shopping_item.dart';
// // import '../models/shopping_list.dart';

// // class ListDetailScreen extends StatefulWidget {
// //   final ShoppingList list;
// //   final int userId; // 🆕 Added userId for per-user calculations

// //   const ListDetailScreen({super.key, required this.list, required this.userId});

// //   @override
// //   State<ListDetailScreen> createState() => _ListDetailScreenState();
// // }

// // class _ListDetailScreenState extends State<ListDetailScreen> {
// //   late Future<List<ShoppingItem>> _itemsFuture;

// //   final TextEditingController _itemController = TextEditingController();
// //   final TextEditingController _priceController = TextEditingController();
// //   final TextEditingController _quantityController = TextEditingController(
// //     text: '1',
// //   );

// //   // 🆕 Budget variables
// //   double _totalBudget = 0.0;
// //   double _totalSpent = 0.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadItems();
// //     _loadBudgetData();
// //   }

// //   void _loadItems() {
// //     _itemsFuture = DBHelper().getItems(widget.list.id!);
// //   }

// //   // 🆕 Load budget and spent for this user
// //   Future<void> _loadBudgetData() async {
// //     final dbHelper = DBHelper();
// //     final budget = await dbHelper.getBudget(widget.userId);
// //     final spent = await dbHelper.getTotalSpent(widget.userId);

// //     if (!mounted) return;
// //     setState(() {
// //       _totalBudget = budget;
// //       _totalSpent = spent;
// //     });
// //   }

// //   // ---------------- ADD ITEM ----------------
// //   void _addItem() async {
// //     if (_itemController.text.trim().isEmpty) return;

// //     final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
// //     final int quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

// //     await DBHelper().insertItem(
// //       ShoppingItem(
// //         listId: widget.list.id!,
// //         name: _itemController.text.trim(),
// //         price: price,
// //         quantity: quantity,
// //         isDone: false,
// //       ),
// //     );

// //     _itemController.clear();
// //     _priceController.clear();
// //     _quantityController.text = '1';

// //     if (!mounted) return;
// //     _loadItems();
// //     _loadBudgetData(); // 🆕 Update spent after adding
// //     setState(() {});
// //   }

// //   // ---------------- TOGGLE ITEM ----------------
// //   void _toggleItem(ShoppingItem item, bool value) async {
// //     await DBHelper().updateItem(
// //       ShoppingItem(
// //         id: item.id,
// //         listId: item.listId,
// //         name: item.name,
// //         price: item.price,
// //         quantity: item.quantity,
// //         isDone: value,
// //       ),
// //     );

// //     if (!mounted) return;
// //     _loadItems();
// //     _loadBudgetData(); // 🆕 Update spent when toggling
// //     setState(() {});
// //   }

// //   // ---------------- DELETE ITEM ----------------
// //   void _deleteItem(int id) async {
// //     await DBHelper().deleteItem(id);

// //     if (!mounted) return;
// //     _loadItems();
// //     _loadBudgetData(); // 🆕 Update spent after deleting
// //     setState(() {});
// //   }

// //   // ---------------- EDIT ITEM ----------------
// //   void _editItem(ShoppingItem item) {
// //     final TextEditingController editNameController = TextEditingController(
// //       text: item.name,
// //     );
// //     final TextEditingController editPriceController = TextEditingController(
// //       text: item.price.toString(),
// //     );
// //     final TextEditingController editQuantityController = TextEditingController(
// //       text: item.quantity.toString(),
// //     );

// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Edit Item'),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             TextField(
// //               controller: editNameController,
// //               decoration: const InputDecoration(labelText: 'Item name'),
// //             ),
// //             const SizedBox(height: 8),
// //             TextField(
// //               controller: editPriceController,
// //               keyboardType: TextInputType.number,
// //               decoration: const InputDecoration(labelText: 'Price'),
// //             ),
// //             const SizedBox(height: 8),
// //             TextField(
// //               controller: editQuantityController,
// //               keyboardType: TextInputType.number,
// //               decoration: const InputDecoration(labelText: 'Quantity'),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             child: const Text('Cancel'),
// //             onPressed: () => Navigator.pop(context),
// //           ),
// //           ElevatedButton(
// //             child: const Text('Save'),
// //             onPressed: () async {
// //               await DBHelper().updateItem(
// //                 ShoppingItem(
// //                   id: item.id,
// //                   listId: item.listId,
// //                   name: editNameController.text.trim(),
// //                   price:
// //                       double.tryParse(editPriceController.text) ?? item.price,
// //                   quantity:
// //                       int.tryParse(editQuantityController.text) ??
// //                       item.quantity,
// //                   isDone: item.isDone,
// //                 ),
// //               );

// //               if (!mounted) return;
// //               Navigator.pop(context);
// //               _loadItems();
// //               _loadBudgetData(); // 🆕 Update spent after editing
// //               setState(() {});
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final remaining = _totalBudget - _totalSpent;
// //     final isOverBudget = remaining < 0;

// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.list.name)),
// //       body: Column(
// //         children: [
// //           // ---------- BUDGET OVERVIEW CARD ----------
// //           Card(
// //             margin: const EdgeInsets.all(12),
// //             elevation: 4,
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Budget Overview',
// //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text('Total Budget: Rs. $_totalBudget'),
// //                   Text('Spent: Rs. $_totalSpent'),
// //                   Text(
// //                     'Remaining: Rs. ${remaining.abs().toStringAsFixed(0)}',
// //                     style: TextStyle(
// //                       color: isOverBudget ? Colors.red : Colors.green,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   if (isOverBudget)
// //                     const Text(
// //                       '⚠ Budget Exceeded!',
// //                       style: TextStyle(color: Colors.red),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // ---------- ADD ITEM INPUT ----------
// //           Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               children: [
// //                 TextField(
// //                   controller: _itemController,
// //                   decoration: const InputDecoration(
// //                     hintText: 'Item name',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: _priceController,
// //                         keyboardType: TextInputType.number,
// //                         decoration: const InputDecoration(
// //                           hintText: 'Price',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: TextField(
// //                         controller: _quantityController,
// //                         keyboardType: TextInputType.number,
// //                         decoration: const InputDecoration(
// //                           hintText: 'Qty',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     IconButton(
// //                       icon: const Icon(Icons.add),
// //                       onPressed: _addItem,
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // ---------- ITEMS LIST ----------
// //           Expanded(
// //             child: FutureBuilder<List<ShoppingItem>>(
// //               future: _itemsFuture,
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }

// //                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //                   return const Center(child: Text('No items yet'));
// //                 }

// //                 final items = snapshot.data!;

// //                 return ListView.builder(
// //                   itemCount: items.length,
// //                   itemBuilder: (context, index) {
// //                     final item = items[index];

// //                     return ListTile(
// //                       leading: Checkbox(
// //                         value: item.isDone,
// //                         onChanged: (value) => _toggleItem(item, value ?? false),
// //                       ),
// //                       title: Text(
// //                         item.name,
// //                         style: TextStyle(
// //                           decoration: item.isDone
// //                               ? TextDecoration.lineThrough
// //                               : null,
// //                         ),
// //                       ),
// //                       subtitle: Text(
// //                         'Rs. ${item.price} × ${item.quantity} = Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
// //                       ),
// //                       trailing: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           IconButton(
// //                             icon: const Icon(Icons.edit, color: Colors.blue),
// //                             onPressed: () => _editItem(item),
// //                           ),
// //                           IconButton(
// //                             icon: const Icon(Icons.delete, color: Colors.red),
// //                             onPressed: () => _deleteItem(item.id!),
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import '../database/db_helper.dart';
// import '../models/shopping_item.dart';
// import '../models/shopping_list.dart';

// class ListDetailScreen extends StatefulWidget {
//   final ShoppingList list;
//   final int userId; // 🆕 Added userId for per-user calculations

//   const ListDetailScreen({super.key, required this.list, required this.userId});

//   @override
//   State<ListDetailScreen> createState() => _ListDetailScreenState();
// }

// class _ListDetailScreenState extends State<ListDetailScreen> {
//   late Future<List<ShoppingItem>> _itemsFuture;

//   final TextEditingController _itemController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController(
//     text: '1',
//   );

//   // 🆕 Search and Filter Controllers
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _filterStatus = 'All'; // 'All', 'Purchased', 'Unpurchased'

//   // 🆕 Budget variables
//   double _totalBudget = 0.0;
//   double _totalSpent = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//     _loadBudgetData();

//     // 🆕 Listen to search input
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.toLowerCase();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _loadItems() {
//     _itemsFuture = DBHelper().getItems(widget.list.id!);
//   }

//   // 🆕 Load budget and spent for this user
//   Future<void> _loadBudgetData() async {
//     final dbHelper = DBHelper();
//     final budget = await dbHelper.getBudget(widget.userId);
//     final spent = await dbHelper.getTotalSpent(widget.userId);

//     if (!mounted) return;
//     setState(() {
//       _totalBudget = budget;
//       _totalSpent = spent;
//     });
//   }

//   // 🆕 Filter and Search Logic
//   List<ShoppingItem> _filterAndSearchItems(List<ShoppingItem> items) {
//     List<ShoppingItem> filteredItems = items;

//     // Apply filter by status
//     if (_filterStatus == 'Purchased') {
//       filteredItems = filteredItems.where((item) => item.isDone).toList();
//     } else if (_filterStatus == 'Unpurchased') {
//       filteredItems = filteredItems.where((item) => !item.isDone).toList();
//     }

//     // Apply search query
//     if (_searchQuery.isNotEmpty) {
//       filteredItems = filteredItems.where((item) {
//         return item.name.toLowerCase().contains(_searchQuery);
//       }).toList();
//     }

//     return filteredItems;
//   }

//   // ---------------- ADD ITEM ----------------
//   void _addItem() async {
//     if (_itemController.text.trim().isEmpty) return;

//     final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
//     final int quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

//     await DBHelper().insertItem(
//       ShoppingItem(
//         listId: widget.list.id!,
//         name: _itemController.text.trim(),
//         price: price,
//         quantity: quantity,
//         isDone: false,
//       ),
//     );

//     _itemController.clear();
//     _priceController.clear();
//     _quantityController.text = '1';

//     if (!mounted) return;
//     _loadItems();
//     _loadBudgetData(); // 🆕 Update spent after adding
//     setState(() {});
//   }

//   // ---------------- TOGGLE ITEM ----------------
//   void _toggleItem(ShoppingItem item, bool value) async {
//     await DBHelper().updateItem(
//       ShoppingItem(
//         id: item.id,
//         listId: item.listId,
//         name: item.name,
//         price: item.price,
//         quantity: item.quantity,
//         isDone: value,
//       ),
//     );

//     if (!mounted) return;
//     _loadItems();
//     _loadBudgetData(); // 🆕 Update spent when toggling
//     setState(() {});
//   }

//   // ---------------- DELETE ITEM ----------------
//   void _deleteItem(int id) async {
//     await DBHelper().deleteItem(id);

//     if (!mounted) return;
//     _loadItems();
//     _loadBudgetData(); // 🆕 Update spent after deleting
//     setState(() {});
//   }

//   // ---------------- EDIT ITEM ----------------
//   void _editItem(ShoppingItem item) {
//     final TextEditingController editNameController = TextEditingController(
//       text: item.name,
//     );
//     final TextEditingController editPriceController = TextEditingController(
//       text: item.price.toString(),
//     );
//     final TextEditingController editQuantityController = TextEditingController(
//       text: item.quantity.toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Item'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: editNameController,
//               decoration: const InputDecoration(labelText: 'Item name'),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: editPriceController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Price'),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: editQuantityController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Quantity'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           ElevatedButton(
//             child: const Text('Save'),
//             onPressed: () async {
//               await DBHelper().updateItem(
//                 ShoppingItem(
//                   id: item.id,
//                   listId: item.listId,
//                   name: editNameController.text.trim(),
//                   price:
//                       double.tryParse(editPriceController.text) ?? item.price,
//                   quantity:
//                       int.tryParse(editQuantityController.text) ??
//                       item.quantity,
//                   isDone: item.isDone,
//                 ),
//               );

//               if (!mounted) return;
//               Navigator.pop(context);
//               _loadItems();
//               _loadBudgetData(); // 🆕 Update spent after editing
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final remaining = _totalBudget - _totalSpent;
//     final isOverBudget = remaining < 0;

//     return Scaffold(
//       appBar: AppBar(title: Text(widget.list.name)),
//       body: Column(
//         children: [
//           // ---------- BUDGET OVERVIEW CARD ----------
//           Card(
//             margin: const EdgeInsets.all(12),
//             elevation: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Budget Overview',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text('Total Budget: Rs. $_totalBudget'),
//                   Text('Spent: Rs. $_totalSpent'),
//                   Text(
//                     'Remaining: Rs. ${remaining.abs().toStringAsFixed(0)}',
//                     style: TextStyle(
//                       color: isOverBudget ? Colors.red : Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (isOverBudget)
//                     const Text(
//                       '⚠ Budget Exceeded!',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // ---------- 🆕 SEARCH BAR ----------
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search items...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() {
//                             _searchQuery = '';
//                           });
//                         },
//                       )
//                     : null,
//                 border: const OutlineInputBorder(),
//               ),
//             ),
//           ),

//           // ---------- 🆕 FILTER CHIPS ----------
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 const Text(
//                   'Filter: ',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 8),
//                 ChoiceChip(
//                   label: const Text('All'),
//                   selected: _filterStatus == 'All',
//                   onSelected: (selected) {
//                     setState(() {
//                       _filterStatus = 'All';
//                     });
//                   },
//                 ),
//                 const SizedBox(width: 8),
//                 ChoiceChip(
//                   label: const Text('Purchased'),
//                   selected: _filterStatus == 'Purchased',
//                   onSelected: (selected) {
//                     setState(() {
//                       _filterStatus = 'Purchased';
//                     });
//                   },
//                 ),
//                 const SizedBox(width: 8),
//                 ChoiceChip(
//                   label: const Text('Unpurchased'),
//                   selected: _filterStatus == 'Unpurchased',
//                   onSelected: (selected) {
//                     setState(() {
//                       _filterStatus = 'Unpurchased';
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // ---------- ADD ITEM INPUT ----------
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _itemController,
//                   decoration: const InputDecoration(
//                     hintText: 'Item name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _priceController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           hintText: 'Price',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         controller: _quantityController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           hintText: 'Qty',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.add),
//                       onPressed: _addItem,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // ---------- ITEMS LIST ----------
//           Expanded(
//             child: FutureBuilder<List<ShoppingItem>>(
//               future: _itemsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No items yet'));
//                 }

//                 // 🆕 Apply filter and search
//                 final allItems = snapshot.data!;
//                 final filteredItems = _filterAndSearchItems(allItems);

//                 // 🆕 Show message if no results after filtering/searching
//                 if (filteredItems.isEmpty) {
//                   return const Center(child: Text('No items found'));
//                 }

//                 return ListView.builder(
//                   itemCount: filteredItems.length,
//                   itemBuilder: (context, index) {
//                     final item = filteredItems[index];

//                     return ListTile(
//                       leading: Checkbox(
//                         value: item.isDone,
//                         onChanged: (value) => _toggleItem(item, value ?? false),
//                       ),
//                       title: Text(
//                         item.name,
//                         style: TextStyle(
//                           decoration: item.isDone
//                               ? TextDecoration.lineThrough
//                               : null,
//                         ),
//                       ),
//                       subtitle: Text(
//                         'Rs. ${item.price} × ${item.quantity} = Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () => _editItem(item),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _deleteItem(item.id!),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';

class ListDetailScreen extends StatefulWidget {
  final ShoppingList list;
  final int userId;

  const ListDetailScreen({super.key, required this.list, required this.userId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  late Future<List<ShoppingItem>> _itemsFuture;

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  // 🆕 Search and Filter Controllers
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All'; // 'All', 'Purchased', 'Unpurchased'

  @override
  void initState() {
    super.initState();
    _loadItems();

    // 🆕 Listen to search input
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadItems() {
    _itemsFuture = DBHelper().getItems(widget.list.id!);
  }

  // 🆕 Filter and Search Logic
  List<ShoppingItem> _filterAndSearchItems(List<ShoppingItem> items) {
    List<ShoppingItem> filteredItems = items;

    // Apply filter by status
    if (_filterStatus == 'Purchased') {
      filteredItems = filteredItems.where((item) => item.isDone).toList();
    } else if (_filterStatus == 'Unpurchased') {
      filteredItems = filteredItems.where((item) => !item.isDone).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.name.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filteredItems;
  }

  // ---------------- ADD ITEM ----------------
  void _addItem() async {
    if (_itemController.text.trim().isEmpty) return;

    final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final int quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

    await DBHelper().insertItem(
      ShoppingItem(
        listId: widget.list.id!,
        name: _itemController.text.trim(),
        price: price,
        quantity: quantity,
        isDone: false,
      ),
    );

    _itemController.clear();
    _priceController.clear();
    _quantityController.text = '1';

    if (!mounted) return;
    _loadItems();
    setState(() {});
  }

  // ---------------- TOGGLE ITEM ----------------
  void _toggleItem(ShoppingItem item, bool value) async {
    await DBHelper().updateItem(
      ShoppingItem(
        id: item.id,
        listId: item.listId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        isDone: value,
      ),
    );

    if (!mounted) return;
    _loadItems();
    setState(() {});
  }

  // ---------------- DELETE ITEM ----------------
  void _deleteItem(int id) async {
    await DBHelper().deleteItem(id);

    if (!mounted) return;
    _loadItems();
    setState(() {});
  }

  // ---------------- EDIT ITEM ----------------
  void _editItem(ShoppingItem item) {
    final TextEditingController editNameController = TextEditingController(
      text: item.name,
    );
    final TextEditingController editPriceController = TextEditingController(
      text: item.price.toString(),
    );
    final TextEditingController editQuantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editNameController,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: editPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: editQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              await DBHelper().updateItem(
                ShoppingItem(
                  id: item.id,
                  listId: item.listId,
                  name: editNameController.text.trim(),
                  price:
                      double.tryParse(editPriceController.text) ?? item.price,
                  quantity:
                      int.tryParse(editQuantityController.text) ??
                      item.quantity,
                  isDone: item.isDone,
                ),
              );

              if (!mounted) return;
              Navigator.pop(context);
              _loadItems();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.list.name)),
      body: Column(
        children: [
          // ---------- 🆕 SEARCH BAR ----------
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // ---------- 🆕 FILTER CHIPS ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text(
                  'Filter: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filterStatus == 'All',
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Purchased'),
                  selected: _filterStatus == 'Purchased',
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = 'Purchased';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Unpurchased'),
                  selected: _filterStatus == 'Unpurchased',
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = 'Unpurchased';
                    });
                  },
                ),
              ],
            ),
          ),

          // ---------- ADD ITEM INPUT ----------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    hintText: 'Item name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Qty',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addItem,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---------- ITEMS LIST ----------
          Expanded(
            child: FutureBuilder<List<ShoppingItem>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items yet'));
                }

                // 🆕 Apply filter and search
                final allItems = snapshot.data!;
                final filteredItems = _filterAndSearchItems(allItems);

                // 🆕 Show message if no results after filtering/searching
                if (filteredItems.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return ListTile(
                      leading: Checkbox(
                        value: item.isDone,
                        onChanged: (value) => _toggleItem(item, value ?? false),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        'Rs. ${item.price} × ${item.quantity} = Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editItem(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteItem(item.id!),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
