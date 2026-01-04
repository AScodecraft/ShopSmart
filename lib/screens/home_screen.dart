// ignore_for_file: prefer_final_fields, unrelated_type_equality_checks, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/shopping_list.dart';
import '../models/user.dart';
import 'list_detail_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final Function(bool) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final DBHelper dbHelper = DBHelper();

  List<ShoppingList> _allLists = [];
  List<ShoppingList> _filteredLists = [];
  Map<int, int> _listItemCounts = {}; // Store item counts for each list
  Map<int, double> _listTotalCosts = {}; // Store total costs for each list

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isBudgetExpanded = false;

  late AnimationController _animationController;

  double _totalBudget = 0.0;
  double _totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLists();
    _loadBudgetData();
    _searchController.addListener(_filterLists);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ---------------- LOAD LISTS ----------------
  Future<void> _loadLists() async {
    if (widget.user.id == null) return;

    final lists = await dbHelper.getListsByUser(widget.user.id!);

    // Load item counts and costs for each list
    for (var list in lists) {
      final items = await dbHelper.getItems(list.id!);
      _listItemCounts[list.id!] = items.length;

      // Calculate total cost for checked items
      double totalCost = 0.0;
      for (var item in items) {
        if (item.isDone == 1) {
          totalCost += (item.price * item.quantity);
        }
      }
      _listTotalCosts[list.id!] = totalCost;
    }

    setState(() {
      _allLists = lists;
      _filteredLists = lists;
    });
  }

  // ---------------- LOAD BUDGET ----------------
  Future<void> _loadBudgetData() async {
    if (widget.user.id == null) return;

    final budget = await dbHelper.getBudget(widget.user.id!);
    final spent = await dbHelper.getTotalSpent(widget.user.id!);

    setState(() {
      _totalBudget = budget;
      _totalSpent = spent;
    });
  }

  // ---------------- SEARCH FILTER ----------------
  void _filterLists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLists = query.isEmpty
          ? _allLists
          : _allLists
                .where((list) => list.name.toLowerCase().contains(query))
                .toList();
    });
  }

  void _closeSearchIfOpen() {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _animationController.reverse();
        _searchController.clear();
        _filteredLists = _allLists;
      });
    }
  }

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  Future<void> _deleteList(int id, String name) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 183, 92, 86),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await dbHelper.deleteList(id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('List "$name" deleted'),
        backgroundColor: Colors.green,
      ),
    );

    await _loadLists();
    await _loadBudgetData();
  }

  void _editList(ShoppingList list) {
    final controller = TextEditingController(text: list.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit List Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'List Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('List name cannot be empty')),
                );
                return;
              }

              await dbHelper.updateList(
                ShoppingList(
                  id: list.id,
                  name: controller.text.trim(),
                  userId: widget.user.id,
                ),
              );

              if (!mounted) return;
              Navigator.pop(context);
              await _loadLists();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _setBudget() {
    final controller = TextEditingController(
      text: _totalBudget > 0 ? _totalBudget.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter budget (Rs)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid budget')),
                );
                return;
              }

              await dbHelper.saveBudget(value, widget.user.id!);

              if (!mounted) return;
              Navigator.pop(context);

              await _loadBudgetData();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Budget set to Rs. ${value.toStringAsFixed(0)}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        _filteredLists = _allLists;
      }
    });
  }

  void _toggleBudgetExpansion() {
    setState(() {
      _isBudgetExpanded = !_isBudgetExpanded;
    });
  }

  // ✅ Enhanced Compact Budget Bar with Progress
  Widget _buildCompactBudgetBar(ColorScheme colorScheme) {
    final remaining = _totalBudget - _totalSpent;
    final isOverBudget = remaining < 0;
    final budgetProgress = _totalBudget > 0
        ? (_totalSpent / _totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: _toggleBudgetExpansion,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget: Rs. ${_totalBudget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(
                              _isBudgetExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Spent: Rs. ${_totalSpent.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              'Left: Rs. ${remaining.abs().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverBudget ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: budgetProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? Colors.red : colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Expanded Budget Card
  Widget _buildExpandedBudgetCard(ColorScheme colorScheme) {
    final remaining = _totalBudget - _totalSpent;
    final isOverBudget = remaining < 0;
    final budgetProgress = _totalBudget > 0
        ? (_totalSpent / _totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: _toggleBudgetExpansion,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Circular Progress Indicator
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: budgetProgress,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? Colors.red : colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(budgetProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOverBudget ? 'Over Budget' : 'Used',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Budget Details
            _buildBudgetRow(
              'Total Budget',
              'Rs. ${_totalBudget.toStringAsFixed(0)}',
              Icons.account_balance_wallet,
              colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _buildBudgetRow(
              'Total Spent',
              'Rs. ${_totalSpent.toStringAsFixed(0)}',
              Icons.shopping_cart,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildBudgetRow(
              'Remaining',
              '${isOverBudget ? "-" : ""}Rs. ${remaining.abs().toStringAsFixed(0)}',
              isOverBudget ? Icons.warning : Icons.check_circle,
              isOverBudget ? Colors.red : Colors.green,
            ),

            if (isOverBudget) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have exceeded your budget!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _setBudget,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Update Budget'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ✅ Enhanced List Card with Icons and Info
  Widget _buildListCard(ShoppingList list, ColorScheme colorScheme) {
    final itemCount = _listItemCounts[list.id] ?? 0;
    final totalCost = _listTotalCosts[list.id] ?? 0.0;

    // Different icons for variety
    final icons = [
      Icons.shopping_basket,
      Icons.shopping_bag,
      Icons.shopping_cart,
      Icons.local_grocery_store,
      Icons.store,
    ];
    final iconIndex = (list.id ?? 0) % icons.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          _closeSearchIfOpen();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ListDetailScreen(list: list, userId: widget.user.id!),
            ),
          );
          await _loadLists();
          await _loadBudgetData();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // List Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icons[iconIndex],
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // List Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$itemCount items',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        if (totalCost > 0) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.currency_rupee,
                            size: 16,
                            color: Colors.green,
                          ),
                          Text(
                            totalCost.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editList(list),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _deleteList(list.id!, list.name),
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Shopping Lists Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first list to get started!',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/create-list',
                arguments: widget.user.id,
              ).then((_) async {
                await _loadLists();
                await _loadBudgetData();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Create First List'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${widget.user.name.isNotEmpty ? widget.user.name : 'User'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    user: widget.user,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );

              if (updatedUser != null) {
                setState(() {
                  widget.user.name = updatedUser.name;
                  widget.user.email = updatedUser.email;
                  widget.user.password = updatedUser.password;
                });
              }
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Budget Card - Compact or Expanded
                AnimatedCrossFade(
                  firstChild: _buildCompactBudgetBar(colorScheme),
                  secondChild: _buildExpandedBudgetCard(colorScheme),
                  crossFadeState: _isBudgetExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

                const SizedBox(height: 16),

                // Create New List Button with Icon
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/create-list',
                        arguments: widget.user.id,
                      ).then((_) async {
                        await _loadLists();
                        await _loadBudgetData();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New List'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Lists Section
                Expanded(
                  child: _filteredLists.isEmpty
                      ? (_allLists.isEmpty
                            ? _buildEmptyState()
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No matching lists found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                      : ListView.builder(
                          itemCount: _filteredLists.length,
                          itemBuilder: (context, index) {
                            final list = _filteredLists[index];
                            return _buildListCard(list, colorScheme);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Search Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _isSearching ? 0 : -70,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: colorScheme.surface,
              child: Center(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search your lists...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
