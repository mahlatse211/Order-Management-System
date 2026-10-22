import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Required for picking images
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/ordersScreen.dart';
import 'package:kgs/screens/profile.dart';
import 'package:kgs/screens/service_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewOrderScreen extends StatefulWidget {
  final String? preselectedService; 

  const NewOrderScreen({super.key, this.preselectedService});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  late String _selectedService; 
  
  final _titleController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _budgetController = TextEditingController();
  
  bool _isLoading = false;

  // --- Image Picker Variables ---
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _services = ['Logo Design', 'Brand Design', 'Website Design', 'Event Promotion', 'Print Design', 'Digital Design'];

  // --- Service Images Map ---
  // These images will show in the dropdown. Replace with your actual URLs.
  final Map<String, String> _serviceImages = {
    'Logo Design': 'assets/Logo2.jpeg',
    'Brand Design': 'assets/Brand Design.jpeg',
    'Website Design': '',
    'Event Promotion': 'https://images.unsplash.com/photo-1558655146-d09347e92766?q=80&w=100&auto=format&fit=crop',
    'Print Design': 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=100&auto=format&fit=crop',
    'Digital Design': 'https://images.unsplash.com/photo-1572044162444-ad60f128bdea?q=80&w=100&auto=format&fit=crop',
  };

  // --- Price Ranges Logic ---
  final Map<String, Map<String, int>> _serviceRates = {
    'Logo Design': {'min': 150, 'max': 300},
    'Brand Design': {'min': 500, 'max': 1000},
    'Website Design': {'min': 800, 'max': 2500},
    'Event Promotion': {'min': 100, 'max': 250},
    'Print Design': {'min': 50, 'max': 150},
    'Digital Design': {'min': 200, 'max': 500},
  };

  @override
  void initState() {
    super.initState();
    _selectedService = widget.preselectedService ?? 'Logo Design';
    
    if (!_services.contains(_selectedService)) {
      _selectedService = 'Logo Design';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // --- Function to pick image ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- Calculate Price Range based on Quantity ---
  String get _estimatedPrice {
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final rates = _serviceRates[_selectedService] ?? {'min': 0, 'max': 0};
    
    final minTotal = rates['min']! * qty;
    final maxTotal = rates['max']! * qty;
    
    return 'R$minTotal - R$maxTotal';
  }

  Future<void> _submitOrder() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception("You must be logged in to place an order.");
      }

      // 1. Fetch Customer ID
      final customerRecord = await Supabase.instance.client
          .from('customers')
          .select('id')
          .eq('auth_id', user.id)
          .single();

      final int customerId = customerRecord['id'];

      // 2. Upload Image to Supabase Storage (if one was selected)
      String? uploadedImageUrl;
      
      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';
        
        // Upload to 'order-references' bucket
        await Supabase.instance.client.storage
            .from('order-references')
            .upload(fileName, _selectedImage!);

        // Get the public URL
        uploadedImageUrl = Supabase.instance.client.storage
            .from('order-references')
            .getPublicUrl(fileName);
      }

      // 3. Insert into Database
      await Supabase.instance.client.from('orders').insert({
        'customer_id': customerId, 
        'service_name': _selectedService, 
        'description': _titleController.text.trim(),
        'quantity': int.tryParse(_qtyController.text) ?? 1,
        // 'budget': double.tryParse(_budgetController.text.trim()) ?? 0.0,
        'status': 'Pending',
        // 'notes': _notesController.text.trim(), 
        // 'reference_image_url': uploadedImageUrl, 
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentOrdersScreen())); 
  }
  
  void goToHome() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())); 
  }
  
  void goToPlaceOrder() {
    Navigator.pop(context); 
  }
  void goToServices() {
    Navigator.pop(context); 
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen())); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Order'), 
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfile,
        onSignout: signOut,
        onViewOrdersTap: goToOrders, 
        onHomeTap: goToHome, 
        onPlaceOrderTap: goToPlaceOrder, 
        onServiceTap: goToServices,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select a service', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          
          // --- UPDATED DROPDOWN ---
          DropdownButtonFormField<String>(
            value: _selectedService,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            items: _services.map((s) {
              return DropdownMenuItem<String>(
                value: s,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text on the left
                    Expanded(
                      child: Text(
                        s,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Picture on the far right
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: NetworkImage(_serviceImages[s]!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedService = val;
                });
              }
            },
          ),
          const SizedBox(height: 15),
          
          // TextField(
          //   controller: _titleController, 
          //   decoration: const InputDecoration(labelText: 'Order Title / Brief Description')
          // ),
          TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline, color: Colors.black),
                    hintText: 'Order Title/ Brief Description',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
          
          // --- Quantity Field with dynamic price estimate ---
          // TextField(
          //   controller: _qtyController, 
          //   keyboardType: TextInputType.number, 
          //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          //   decoration: InputDecoration(
          //     labelText: 'Quantity',
          //     helperText: 'Estimated Price: $_estimatedPrice', 
          //     helperStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          //   ),
          //   onChanged: (value) {
          //     setState(() {}); 
          //   },
          // ),
          //Quantity Text Field
          TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number, 
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.numbers, color: Colors.black),
                    hintText: 'Quantity',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
          
          // TextField(
          //   controller: _notesController, 
          //   maxLines: 3, 
          //   decoration: const InputDecoration(labelText: 'Additional Notes')
          // ),
          
          // TextField(
          //   controller: _budgetController,
          //   keyboardType: const TextInputType.numberWithOptions(decimal: true), 
          //   inputFormatters: [
          //     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), 
          //   ],
          //   decoration: const InputDecoration(
          //     labelText: 'Enter Your Budget (R)',
          //   ),
          // ),

          // const SizedBox(height: 20),

          // --- Image Upload UI ---
          const Text('Reference Image (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tap to upload a reference picture', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              padding: const EdgeInsets.all(15)
            ),
            onPressed: _isLoading ? null : _submitOrder,
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Submit Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}