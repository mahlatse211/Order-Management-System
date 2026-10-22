import 'package:flutter/material.dart';
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/newOrder.dart';
import 'package:kgs/screens/profile.dart';
import 'package:kgs/screens/service_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CurrentOrdersScreen extends StatefulWidget {
  const CurrentOrdersScreen({super.key});

  @override
  State<CurrentOrdersScreen> createState() => _CurrentOrdersScreenState();
}

class _CurrentOrdersScreenState extends State<CurrentOrdersScreen> {
  // Get the current user ID
  // final String? userId = Supabase.instance.client.auth.currentUser?.id;
  // final String ?user = Supabase.instance.client.auth.currentUser?.id;

  // // Fetch orders from Supabase where the user_id matches the logged-in user
  // Future<List<Map<String, dynamic>>> _fetchCurrentOrders() async
  //  {
  //    if (user == null) throw Exception("User not logged in");

  //   // NOTE: Change 'orders' to your actual table name if it's different
  //   final response = await Supabase.instance.client
  //       .from('orders')
  //       .select()
  //       .eq('order_id', user!) // Filter by the current user
  //       .order('created_at', ascending: false); // Show newest orders first

  //   return response;
  // }

  Future<List<Map<String, dynamic>>> _fetchCurrentOrders() async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;

  if (currentUser == null) {
    throw Exception('User not logged in');
  }

  try {
    // Find this user's integer customer ID.
    final customer = await supabase
        .from('customers')
        .select('id')
        .eq('auth_id', currentUser.id)
        .maybeSingle();

    if (customer == null) {
      throw Exception('Customer record not found');
    }

    final int customerId = customer['id'] as int;

    debugPrint('Customer ID: $customerId');

    // Fetch orders belonging to this customer.
    final response = await supabase
        .from('orders')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    debugPrint('Orders found: ${response.length}');

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    debugPrint('Error fetching current orders: $e');
    rethrow;
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
    // If we are already on profile page, just close the drawer
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage(),)); 
  }
  void goToOrders() {
    // If we are already on orders page, just close the drawer
    Navigator.pop(context);
    // go to orders page
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentOrdersScreen(),)); // Navigate to orders page
  }
  void goToHome() {
    // If we are already on home page, just close the drawer
    Navigator.pop(context);
    // go to home page
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen(),)); // Navigate to home page
  }
  void goToPlaceOrder() {
    // If we are already on place order page, just close the drawer
    Navigator.pop(context);
    // go to place order page
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen(),)); // Navigate to place order page
  }
  void goToService() {
    // If we are already on service page, just close the drawer
    Navigator.pop(context);
    // go to service page
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen(),)); // Navigate to service page
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Current Orders'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfile,
        onSignout: signOut,
        onViewOrdersTap: goToOrders, // Navigate to orders page
        onHomeTap: goToHome, // Navigate to home page
        onPlaceOrderTap: goToPlaceOrder, // Navigate to place order page
        onServiceTap: goToService, // Navigate to service page
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCurrentOrders(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            // Replace Center with Align and set alignment to bottomCenter
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24.0), // Add some padding so it's not flush with the edge
                child: Text(
                  'Error loading orders: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // 3. Empty State (No orders found)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no current orders.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 4. Data State (Show the orders)
          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              
              // Replace these keys with the actual column names from your Supabase 'orders' table
              final orderId = order['service_name'] ?? 'N/A';
              final orderStatus = order['status'] ?? 'Pending';
              final orderDate = order['created_at'] != null 
                  ? order['created_at'].toString().substring(0, 10) // Simple date format
                  : 'Unknown Date';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.black),
                  title: Text(
                    'Order #$orderId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Date: $orderDate\nStatus: $orderStatus'),
                  trailing: TextButton(
                    onPressed: () {
                      // Optional: Navigate to an Order Details page
                      // Navigator.push(...);
                    },
                    child: const Text('View'),
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