class Budget {
  final int? id;
  final int userId; // 🆕 Link budget to user
  final double totalBudget;

  Budget({this.id, required this.userId, required this.totalBudget});

  /// Convert Budget object to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // 🆕 Save userId
      'total_budget': totalBudget,
    };
  }

  /// Create Budget object from Map (from SQLite)
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      userId: map['userId'], // 🆕 Fetch userId
      totalBudget: map['total_budget'],
    );
  }
}
