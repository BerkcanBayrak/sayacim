import 'dart:convert';

class MealItem {
  final String name;
  final String calories;
  final String type; // 'Breakfast', 'Lunch', 'Dinner'

  MealItem({required this.name, required this.calories, required this.type});

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      calories: json['calories'] ?? '',
      type: json['type'] ?? 'Lunch',
    );
  }
}

class DailyMenu {
  final DateTime date;
  final List<MealItem> items;
  final int totalCalories;

  DailyMenu({
    required this.date,
    required this.items,
    required this.totalCalories,
  });
  
  List<MealItem> get breakfast => items.where((i) => i.type == 'Breakfast').toList();
  List<MealItem> get lunch => items.where((i) => i.type == 'Lunch').toList();
  List<MealItem> get dinner => items.where((i) => i.type == 'Dinner').toList();

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<MealItem> menuItems = list.map((i) => MealItem.fromJson(i)).toList();
    
    return DailyMenu(
      date: DateTime.parse(json['date']),
      items: menuItems,
      totalCalories: json['totalCalories'] ?? 0,
    );
  }
}
