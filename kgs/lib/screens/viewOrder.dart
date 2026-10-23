import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Order Model Class
class Order {
  final String orderId;
  final String description;
  final String serviceName;
  final String status;
  final double? budget;
  final DateTime? deadline;
  final String message;

  Order({
    required this.orderId,
    required this.description,
    required this.status,
    required this.serviceName,
    this.budget,
    this.deadline,
    required this.message,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['order_id'].toString(),
      description: map['description'] ?? '',
      serviceName: map['service_name'] ?? '',
      status: map['status'] ?? 'Pending',
      budget: (map['budget'] as num?)?.toDouble(),
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      message:map['admin_message']?? '',
    );
  }
}

// 2. Order Detail Screen Widget
class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String serviceName;

  const OrderDetailScreen({Key? key, required this.orderId, required this.serviceName}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Order?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = fetchOrderDetails();
  }

  Future<Order?> fetchOrderDetails() async {
    final response = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('order_id', widget.orderId)
        .single();

    return Order.fromMap(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details : ${widget.serviceName}'),
      ),
      body: FutureBuilder<Order?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading order: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Order not found.'));
          }

          final order = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              order.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: order.status.toLowerCase() == 'completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          'Order ID:',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.description.isEmpty ? 'No description provided' : order.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Budget',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              order.budget != null ? 'R ${order.budget!.toStringAsFixed(2)}' : 'Not Set',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Deadline',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              order.deadline != null
                                  ? order.deadline.toString().split(' ')[0]
                                  : 'No deadline',
                            ),
                        //     Text(
                        //   'Message From Admin',
                        //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        // ),
                        // Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        const Text(
                          'Message From Admin: ',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          order.message.isEmpty ? 'No description provided' : order.message,
                          style: const TextStyle(fontSize: 16),
                        ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}