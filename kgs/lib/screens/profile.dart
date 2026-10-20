import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/drawer.dart'; // Ensure path is correct

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 1. Get the current user
  final User? currentUser = Supabase.instance.client.auth.currentUser;

  // 2. Create a Future to fetch the customer details from the database
  Future<Map<String, dynamic>> _getCustomerDetails() async {
    if (currentUser == null) {
      throw Exception("No user logged in");
    }
    
    // Fetch the row from the 'customers' table where user_id matches
    final response = await Supabase.instance.client
        .from('customers')
        .select()
        .eq('user_id', currentUser!.id)
        .single(); // .single() expects exactly one row
        
    return response;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfile,
        onSignout: signOut,
      ),
      // 3. Use FutureBuilder to wait for the database fetch
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getCustomerDetails(),
        builder: (context, snapshot) {
          // While loading, show a spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's an error (e.g., row not found), show error message
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // If data is successfully fetched
          if (snapshot.hasData) {
            final customerData = snapshot.data!;
            final fullName = customerData['full_name'] ?? 'No Name';
            final phone = customerData['phone'] ?? 'No Phone';
            // We can use the email from the database or the auth object
            final email = customerData['email'] ?? currentUser?.email ?? 'No Email';

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                _buildProfileItem(Icons.person, 'Full Name', fullName),
                _buildProfileItem(Icons.email, 'Email', email),
                _buildProfileItem(Icons.phone, 'Phone Number', phone),
                // You can also show the user ID for debugging
                _buildProfileItem(Icons.fingerprint, 'User ID', currentUser!.id),
              ],
            );
          }

          return const Center(child: Text('No data found'));
        },
      ),
    );
  }

  // A helper widget to make the list look nice
  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}