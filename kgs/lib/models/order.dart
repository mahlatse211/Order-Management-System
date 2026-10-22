// class Order
// {
// //
// final String orderId;
// final String description;
// final String Status;
// final int budget;
// final DateTime deadline;
// final String serviceName;

// Order({

// required this.orderId,
// required this.description,
// required this.Status,
// required this.budget,
// required this.deadline,
// required this.serviceName,






// })
// }

class Order {
  final String id;
  final String customerId;
  final double totalAmount;
  final String status;
  final List<dynamic> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerId,
    required this.totalAmount,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'].toString(),
      customerId: map['customer_id'] ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Pending',
      items: map['items'] ?? [],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}