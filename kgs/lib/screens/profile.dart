import 'package:flutter/material.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/newOrder.dart';
import 'package:kgs/screens/ordersScreen.dart';
import 'package:kgs/screens/service_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/login.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = Supabase.instance.client.auth.currentUser;

  // --- State variables ---
  bool _isSaving = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  int _orderCount = 0;
  Map<String, dynamic> _profileData = {};

  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // Password Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // 1. Fetch profile data
  Future<void> _fetchProfileData() async {
    if (currentUser == null) {
      setState(() {
        _errorMessage = "No user logged in";
        _isLoading = false;
      });
      return;
    }
    
    try {
      final response = await Supabase.instance.client
          .from('customers')
          .select()
          .eq('auth_id', currentUser!.id)
          .single();
          
      final int customerId = response['id'];
      final ordersResponse = await Supabase.instance.client
          .from('orders')
          .select('order_id')
          .eq('customer_id', customerId);

      setState(() {
        _profileData = response;
        _nameController.text = response['full_name']?.toString() ?? '';
        _emailController.text = currentUser?.email ?? response['email']?.toString() ?? '';
        _phoneController.text = response['phone']?.toString() ?? '';
        _orderCount = ordersResponse.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 2. Save Account Details (Name & Phone)
  Future<void> _saveAccountDetails() async {
    if (currentUser == null) return;
    setState(() => _isSaving = true);

    try {
      await Supabase.instance.client
          .from('customers')
          .update({
            'full_name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(), 
          })
          .eq('auth_id', currentUser!.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account details updated!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // 3. Change Password Logic
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both password fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Step 1: Verify current password by attempting to sign in
      await Supabase.instance.client.auth.signInWithPassword(
        email: currentUser!.email!,
        password: _currentPasswordController.text,
      );

      // Step 2: If successful, update to new password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green),
      );
      
      // Clear fields and close dialog
      _currentPasswordController.clear();
      _newPasswordController.clear();
      Navigator.pop(context); 

    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Show Password Dialog
  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : _changePassword,
              child: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Update Password'),
            ),
          ],
        );
      },
    );
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

  void goToOrders() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentOrdersScreen())).then((_) {
      _fetchProfileData();
    }); 
  }
  void goToHome() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())); 
  }

  @override
  Widget build(BuildContext context) {
    Color headerColor = const Color.fromARGB(255, 0, 0, 0); 

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _buildBody(headerColor),
    );
  }

  Widget _buildBody(Color headerColor) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- TOP HEADER ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Padding(
                   padding: const EdgeInsets.only(left: 400.0),
                   child: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: goToHome,
                      tooltip: 'Home Page',
                      color: Colors.white,
                    ),
                 ),
                const Text('Your account', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 5),
                Text(
                  _nameController.text.isNotEmpty ? _nameController.text : 'User Name',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: goToOrders,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.shopping_bag, color: Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('$_orderCount active orders', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          // --- GENERAL MENU LIST ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Logged in text at the top of General
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      'Logged in as: ${currentUser?.email ?? "No Email"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('General', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),

                // 2. Account Details Expansion Tile
                ExpansionTile(
                  leading: Icon(Icons.person_outline, color: Colors.blue[800]),
                  title: const Text('Account details'),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      readOnly: true, // Email usually can't be edited here without breaking Auth
                      decoration: const InputDecoration(labelText: 'Email (Read-only)', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], minimumSize: const Size(double.infinity, 45)),
                      onPressed: _isSaving ? null : _saveAccountDetails,
                      child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Account Details', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),

                // 3. Contact Details Expansion Tile (Read Only)
                ExpansionTile(
                  leading: Icon(Icons.phone_outlined, color: Colors.blue[800]),
                  title: const Text('Contact details'),
                  children: [
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(currentUser?.email ?? 'N/A'),
                      leading: const Icon(Icons.email),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      title: const Text('Phone Number'),
                      subtitle: Text(_phoneController.text.isNotEmpty ? _phoneController.text : 'Not provided'),
                      leading: const Icon(Icons.phone),
                    ),
                  ],
                ),

                // 4. Change Password
                ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.blue[800]),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: _showPasswordDialog,
                ),
                
                const Divider(),

                const SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      Text('You own your data. \nWe do not share your account details or \napp activity with unauthorized third parties.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(height: 20),

                // 5. Sign Out Button at the bottom
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: signOut,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}