class CartItem {
  final int id;
  final String name;
  final int qty;

  CartItem({required this.id, required this.name, required this.qty});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Product',
      qty: json['qty'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'qty': qty};
  }
}
