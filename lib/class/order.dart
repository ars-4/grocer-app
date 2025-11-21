class OrderLine {
  final int productId;
  final String productName;
  final int qty;
  final int amount;

  OrderLine({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.amount,
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    var productInfo = json['product'] as List;
    return OrderLine(
      productId: productInfo.isNotEmpty ? productInfo[0] as int : 0,
      productName: productInfo.length > 1 ? productInfo[1] as String : '',
      qty: json['qty'] as int? ?? 0,
      amount: json['amount'] as int? ?? 0,
    );
  }
}

class Order {
  final int id;
  final String name;
  final int partnerId;
  final String partnerName;
  final int amountTotal;
  final DateTime dateOrder;
  final String state;
  final List<int> tagIds;
  final List<OrderLine> products; 
  final List<int> orderLineIds;

  Order({
    required this.id,
    required this.name,
    required this.partnerId,
    required this.partnerName,
    required this.amountTotal,
    required this.dateOrder,
    required this.state,
    required this.tagIds,
    required this.products,
    required this.orderLineIds,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var partnerInfo = json['partner_id'] is List ? json['partner_id'] as List : [];

    return Order(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      partnerId: partnerInfo.isNotEmpty ? partnerInfo[0] as int : 0,
      partnerName: partnerInfo.length > 1 ? partnerInfo[1] as String : '',
      amountTotal: json['amount_total'] as int? ?? 0,
      dateOrder: DateTime.tryParse(json['date_order'].toString()) ?? DateTime.now(),
      state: json['state'] as String? ?? '',
      tagIds: (json['tag_ids'] as List?)?.map((e) => e as int).toList() ?? [],
      products: (json['products'] as List?)
          ?.map((e) => OrderLine.fromJson(e))
          .toList() ?? [],
      orderLineIds: (json['order_line'] as List?)
          ?.map((e) => e as int)
          .toList() ?? [],
    );
  }
}