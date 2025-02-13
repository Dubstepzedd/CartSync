import 'package:app/models/item.dart';

class Cart {
  final int id;
  final String name;
  final String description;
  final List<Item> items;
  final List<String> usernames;

  Cart({required this.items, required this.usernames, required this.id, required this.name, required this.description});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(),
      usernames: (json['users'] as List<dynamic>).map((e) => e.toString()).toList(),
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}