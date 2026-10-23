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
    // 1. Check the 24-hour rule
    final now = DateTime.now();
    final difference = now.difference(orderDate);
    
    if (difference.inHours > 24) {
      // Time has passed - Show blocking message
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

    // 2. Show confirmation dialog
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

    // 3. Update the database
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

  void goToOrders() {
    Navigator.pop(context); 
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('My Current Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
            return const Center(
              child: Text('You have no current orders.', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
              
              // Parse the date for the time check
              final DateTime orderDate = DateTime.parse(orderDateString).toLocal();
              final String formattedDate = orderDate.toString().substring(0, 10);

              // 2. Calculate if the order is within the 24-hour window
              final difference = DateTime.now().difference(orderDate);
              final bool canCancel = difference.inHours <= 24;

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.black),
                    title: Text(orderService, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Date: $formattedDate\nStatus: $orderStatus'),
                    
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 3. ONLY show cancel button if Status is Pending AND within 24 hours
                        if (orderStatus == 'Pending' && canCancel)
                          TextButton(
                            onPressed: () => _cancelOrder(orderId, orderDate),
                            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                          ),
                        
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailScreen(orderId: orderId, serviceName: orderService),
                              ),
                            );
                          },
                          child: const Text('View'),
                        ),
                      ],
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