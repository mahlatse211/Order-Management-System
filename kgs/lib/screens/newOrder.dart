// Required for Uint8List (Web compatible)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/gallary_screens.dart';
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
  final _deadlineController = TextEditingController();
  DateTime? _selectedDeadline;  
  
  static const int _maxDeadlineDays = 30;
  bool _isLoading = false;

  // 1. FIXED: Use Uint8List instead of File for Web compatibility
  Uint8List? _selectedImageBytes; 
  final ImagePicker _picker = ImagePicker();

  final List<String> _services = ['Logo Design', 'Brand Design', 'Website Design', 'Event Promotion', 'Print Design', 'Digital Design'];

  // 2. FIXED: Use Network URLs instead of local assets
  final Map<String, String> _serviceImages = {
    'Logo Design': 'https://images.unsplash.com/photo-1626785774573-4b799315345d?q=80&w=100&auto=format&fit=crop',
    'Brand Design': 'https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=100&auto=format&fit=crop',
    'Website Design': 'https://images.unsplash.com/photo-1547658719-da2b51169166?q=80&w=100&auto=format&fit=crop',
    'Event Promotion': 'https://images.unsplash.com/photo-1558655146-d09347e92766?q=80&w=100&auto=format&fit=crop',
    'Print Design': 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=100&auto=format&fit=crop',
    'Digital Design': 'https://images.unsplash.com/photo-1572044162444-ad60f128bdea?q=80&w=100&auto=format&fit=crop',
  };

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
    _deadlineController.dispose();
    super.dispose();
  }

  // 3. FIXED: Read the image as Bytes instead of a File
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  String get _estimatedPrice {
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final rates = _serviceRates[_selectedService] ?? {'min': 0, 'max': 0};
    
    final minTotal = rates['min']! * qty;
    final maxTotal = rates['max']! * qty;
    
    return 'R$minTotal - R$maxTotal';
  }

  Future<void> _submitOrder() async {
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an order deadline.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception("You must be logged in to place an order.");
      }

      final customerRecord = await Supabase.instance.client
          .from('customers')
          .select('id')
          .eq('auth_id', user.id)
          .single();

      final int customerId = customerRecord['id'];

      String? uploadedImageUrl;
      
      // 4. FIXED: Use uploadBinary for Web compatibility
      if (_selectedImageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';
        
        await Supabase.instance.client.storage
            .from('KGS')
            .uploadBinary(fileName, _selectedImageBytes!); // Upload bytes

        uploadedImageUrl = Supabase.instance.client.storage
            .from('KGS')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client.from('orders').insert({
        'customer_id': customerId, 
        'service_name': _selectedService, 
        'description': _titleController.text.trim(),
        'quantity': int.tryParse(_qtyController.text) ?? 1,
        'status': 'Pending',
        'deadline': _deadlineController.text,
        'Images': uploadedImageUrl, 
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
  
  void goToGallery() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())); 
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastAllowedDate = today.add(const Duration(days: _maxDeadlineDays));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? today,
      firstDate: today,
      lastDate: lastAllowedDate,
      helpText: 'Select order deadline',
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDeadline = pickedDate;
      _deadlineController.text =
          '${pickedDate.year}-'
          '${pickedDate.month.toString().padLeft(2, '0')}-'
          '${pickedDate.day.toString().padLeft(2, '0')}';
    });
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
        onGalleryTap: goToGallery,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select a service', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          
          DropdownButtonFormField<String>(
            initialValue: _selectedService,
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
                    Expanded(
                      child: Text(s, style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          // 5. FIXED: Using NetworkImage here
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
          
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number, 
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Quantity',
              helperText: 'Estimated Price: $_estimatedPrice', 
              helperStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              prefixIcon: const Icon(Icons.numbers, color: Colors.black),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {}); 
            },
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _deadlineController,
            readOnly: true,
            onTap: _pickDeadline,
            decoration: InputDecoration(
              labelText: 'Order Deadline',
              hintText: 'Select a deadline date',
              prefixIcon: const Icon(Icons.calendar_month),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),

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
              // 6. FIXED: Use Image.memory for the preview
              child: _selectedImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
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