import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/gallary_screens.dart';
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/profile.dart';
import 'package:kgs/screens/service_page.dart';
import 'newOrder.dart';
import 'viewOrder.dart'; 
import 'package:intl/intl.dart'; // Add 'intl' to pubspec.yaml for better date formatting

class CurrentOrdersScreen extends StatefulWidget {
  const CurrentOrdersScreen({super.key});

  @override
  State<CurrentOrdersScreen> createState() => _CurrentOrdersScreenState();
}

class _CurrentOrdersScreenState extends State<CurrentOrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Map<String, dynamic>>> _fetchCurrentOrders() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) throw Exception('User not logged in');

    try {
      final customer = await supabase
          .from('customers')
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();

      if (customer == null) throw Exception('Customer record not found');

      final int customerId = customer['id'] as int;

      final response = await supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching current orders: $e');
      rethrow;
    }
  }

  // --- Cancel Order Logic ---
  Future<void> _cancelOrder(String orderId, DateTime orderDate) async {
    final now = DateTime.now();
    final difference = now.difference(orderDate);
    
    if (difference.inHours > 24) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Cancel'),
          content: const Text('Orders can only be cancelled within 24 hours of placing them. This order is past the cancellation window.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': 'Cancelled'})
          .eq('order_id', orderId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully.'), backgroundColor: Colors.green),
      );
      
      setState(() {}); 
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling order: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void goToProfile() {
    Navigator.pop(context); 
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())); 
  }

  void goToOrders() => Navigator.pop(context); 

  void goToHome() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())); 
  }

  void goToPlaceOrder() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen())); 
  }

  void goToService() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen())); 
  }
  
  void goToGallery() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())); 
  }

  // --- Helper to get Status Color ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light grey background
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfile,
        onSignout: signOut,
        onViewOrdersTap: goToOrders, 
        onHomeTap: goToHome, 
        onPlaceOrderTap: goToPlaceOrder, 
        onServiceTap: goToService, 
        onGalleryTap: goToGallery,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCurrentOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading orders: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // --- COOLER EMPTY STATE ---
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'When you place an order, it will appear here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              
              final orderId = order['order_id'];
              final orderService = order['service_name'] ?? 'N/A';
              final orderStatus = order['status'] ?? 'Pending';
              final orderDateString = order['created_at'];
              
              final DateTime orderDate = DateTime.parse(orderDateString).toLocal();
              final String formattedDate = DateFormat('MMM dd, yyyy').format(orderDate);
              
              final difference = DateTime.now().difference(orderDate);
              final bool canCancel = difference.inHours <= 24;

              final statusColor = _getStatusColor(orderStatus);

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(orderId: orderId, serviceName: orderService),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Title and Status Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  orderService,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  orderStatus.toUpperCase(),
                                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Row 2: Date & Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Date with icon
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 6),
                                  Text(formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                ],
                              ),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  if (orderStatus == 'Pending' && canCancel)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => _cancelOrder(orderId, orderDate),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 13)),
                                    ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}