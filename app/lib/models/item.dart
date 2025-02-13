class Item {
  final int id;
  final String name;
  final String description;
  final String cartName;

  Item({required this.id, required this.name, required this.description, required this.cartName});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cartName: json['cart_id'],
    );
  }

}