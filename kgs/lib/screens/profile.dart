import 'package:flutter/material.dart';
import 'package:kgs/screens/gallary_screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/ordersScreen.dart';
import 'package:kgs/screens/service_page.dart';
import 'newOrder.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? currentUser = Supabase.instance.client.auth.currentUser;

  bool _isSaving = false;
  bool _isLoading = true;
  String? _errorMessage;
  int _orderCount = 0;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
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

  Future<void> _fetchProfileData() async {
    if (currentUser == null) {
      setState(() { _errorMessage = "No user logged in"; _isLoading = false; });
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
        _nameController.text = response['full_name']?.toString() ?? '';
        _emailController.text = currentUser?.email ?? response['email']?.toString() ?? '';
        _phoneController.text = response['phone']?.toString() ?? '';
        _orderCount = ordersResponse.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

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

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both password fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: currentUser!.email!,
        password: _currentPasswordController.text,
      );
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _currentPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
              const SizedBox(height: 10),
              TextField(controller: _newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: _isSaving ? null : _changePassword,
              child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update Password'),
            ),
          ],
        );
      },
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  // Navigation Methods
  void goToProfile() => Navigator.pop(context); 
  void goToOrders() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentOrdersScreen())); }
  void goToHome() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())); }
  void goToPlaceOrder() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen())); }
  void goToService() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen())); }
  void goToGallery() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)));

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- 1. HERO HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                // Name & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : 'User Name',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser?.email ?? 'No Email',
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 2. FLOATING ORDER CARD ---
          Transform.translate(
            offset: const Offset(0, -25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: goToOrders,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag, color: Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text('$_orderCount active orders', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- 3. SETTINGS SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('General', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 12),

                // Custom Expansion Tile for Account Details
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.person_outline, color: Colors.blue),
                      ),
                      title: const Text('Account details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      iconColor: Colors.black,
                      collapsedIconColor: Colors.grey,
                      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      children: [
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: _emailController, readOnly: true, decoration: const InputDecoration(labelText: 'Email (Read-only)', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12)),
                        const SizedBox(height: 12),
                        TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: _isSaving ? null : _saveAccountDetails,
                            child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // Custom Expansion Tile for Contact Details
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.phone_outlined, color: Colors.green),
                      ),
                      title: const Text('Contact details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      iconColor: Colors.black,
                      collapsedIconColor: Colors.grey,
                      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      children: [
                        ListTile(contentPadding: EdgeInsets.zero, title: const Text('Email', style: TextStyle(color: Colors.grey, fontSize: 12)), subtitle: Text(currentUser?.email ?? 'N/A', style: const TextStyle(color: Colors.black87, fontSize: 15))),
                        const Divider(),
                        ListTile(contentPadding: EdgeInsets.zero, title: const Text('Phone Number', style: TextStyle(color: Colors.grey, fontSize: 12)), subtitle: Text(_phoneController.text.isNotEmpty ? _phoneController.text : 'Not provided', style: const TextStyle(color: Colors.black87, fontSize: 15))),
                      ],
                    ),
                  ),
                ),

                // Change Password List Tile
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.lock_outline, color: Colors.purple),
                    ),
                    title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: _showPasswordDialog,
                  ),
                ),

                // Privacy Text
                Center(
                  child: Text(
                    'You own your data.\nWe do not share your account details or\napp activity with unauthorized third parties.', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.5),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: signOut,
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}