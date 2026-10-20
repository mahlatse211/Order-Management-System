import 'package:flutter/material.dart';
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CurrentOrdersScreen extends StatefulWidget {
  const CurrentOrdersScreen({super.key});

  @override
  State<CurrentOrdersScreen> createState() => _CurrentOrdersScreenState();
}

class _CurrentOrdersScreenState extends State<CurrentOrdersScreen> {
  // Get the current user ID
  final String? userId = Supabase.instance.client.auth.currentUser?.id;

  // Fetch orders from Supabase where the user_id matches the logged-in user
  Future<List<Map<String, dynamic>>> _fetchCurrentOrders() async {
    if (userId == null) throw Exception("User not logged in");

    // NOTE: Change 'orders' to your actual table name if it's different
    final response = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('order_id', userId!) // Filter by the current user
        .order('created_at', ascending: false); // Show newest orders first

    return List<Map<String, dynamic>>.from(response);
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
    Navigator.pop(context); 
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
            return Center(
              child: Text('Error loading orders: ${snapshot.error}'),
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
              final orderId = order['id'] ?? 'N/A';
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