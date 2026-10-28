import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/chatbot_screen.dart'; 
import 'package:kgs/screens/invoice_generator.dart'; 
import 'package:intl/intl.dart';

// 1. Order Model Class
class Order {
  final String orderId;
  final String description;
  final String serviceName;
  final String status;
  final double? budget;
  final DateTime? deadline;
  final String message;
  final DateTime? createdAt; 
  final String? images; 

  Order({
    required this.orderId,
    required this.description,
    required this.status,
    required this.serviceName,
    this.budget,
    this.deadline,
    required this.message,
    this.createdAt,
    this.images,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['order_id'].toString(),
      description: map['description'] ?? '',
      serviceName: map['service_name'] ?? '',
      status: map['status'] ?? 'Pending',
      budget: (map['budget'] as num?)?.toDouble(),
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      message: map['admin_message'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']).toLocal() : null,
      images: map['images'] ?? map['Images'], 
    );
  }
}

// 2. Order Detail Screen Widget
class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String serviceName;

  const OrderDetailScreen({super.key, required this.orderId, required this.serviceName});

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

  // Helper for Status Color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'pending':
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
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
          
          bool isWithin24Hours = false;
          if (order.createdAt != null) {
            isWithin24Hours = DateTime.now().difference(order.createdAt!).inHours <= 24;
          }

          final statusColor = _getStatusColor(order.status);
          final bool isCancelled = order.status.toLowerCase() == 'cancelled'; // <--- CHECK IF CANCELLED

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HERO HEADER SECTION ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ORDER DETAILS',
                            style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.serviceName,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${order.orderId.split('-').first.toUpperCase()}...',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- 2. INFO CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      const Text('Project Brief', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        order.description.isEmpty ? 'No description provided.' : order.description,
                        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(height: 1),
                      ),

                      // Budget & Deadline Grid
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Budget', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  order.budget != null ? 'R ${order.budget!.toStringAsFixed(2)}' : 'Not Set',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Deadline', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  order.deadline != null 
                                      ? DateFormat('MMM dd, yyyy').format(order.deadline!)
                                      : 'No deadline',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. IMAGE SECTION ---
                if (order.images != null && order.images!.trim().isNotEmpty) ...[
                  const Text('Reference Image', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final cleanPath = order.images!.trim().replaceFirst(RegExp(r'^/+'), '');
                      final String imageUrl = cleanPath.startsWith('http')
                          ? cleanPath
                          : Supabase.instance.client.storage.from('KGS').getPublicUrl(cleanPath);

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // --- 4. ADMIN MESSAGE ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.campaign, color: Colors.blue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Message from Admin', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              order.message.isEmpty ? 'No message from admin yet.' : order.message,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 5. 24-HOUR WARNING ---
                if (isWithin24Hours && order.status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'You can cancel this order within 24 hours of placing it.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // --- 6. ACTION BUTTONS ---
                Row(
                  children: [
                    // CHAT BUTTON
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCancelled ? Colors.grey[300] : Colors.white,
                          foregroundColor: isCancelled ? Colors.grey[600] : Colors.black,
                          side: BorderSide(color: isCancelled ? Colors.grey[400]! : Colors.black, width: 1.5),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        icon: Icon(Icons.chat_bubble_outline, size: 20, color: isCancelled ? Colors.grey[600] : Colors.black),
                        label: Text(
                          isCancelled ? 'Chat (Cancelled)' : 'Chat', 
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isCancelled ? Colors.grey[600] : Colors.black)
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatbotScreen(
                                orderId: order.orderId,
                                serviceName: order.serviceName,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // INVOICE BUTTON (Only show if NOT cancelled)
                    if (!isCancelled)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          icon: const Icon(Icons.download, size: 20),
                          label: const Text('Invoice', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            InvoiceGenerator.generateAndDownloadInvoice(
                              orderId: order.orderId,
                              serviceName: order.serviceName,
                              status: order.status,
                              description: order.description,
                              deadline: order.deadline != null ? DateFormat('yyyy-MM-dd').format(order.deadline!) : 'Not Set',
                              budget: order.budget != null ? order.budget!.toStringAsFixed(2) : '0.00',
                              adminMessage: order.message,
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}