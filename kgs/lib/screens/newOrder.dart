import 'dart:typed_data'; 
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
  final String? preselectedImageUrl; 
  final String? preselectedTitle; 

  const NewOrderScreen({
    super.key, 
    this.preselectedService, 
    this.preselectedImageUrl,
    this.preselectedTitle,
  });

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

  Uint8List? _selectedImageBytes; 
  final ImagePicker _picker = ImagePicker();

  final List<String> _services = ['Logo Design', 'Brand Design', 'Website Design', 'Event Promotion', 'Print Design', 'Digital Design'];

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
    _selectedService = widget.preselectedTitle ?? widget.preselectedService ?? 'Logo Design';
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
      if (user == null) throw Exception("You must be logged in to place an order.");

      final customerRecord = await Supabase.instance.client
          .from('customers')
          .select('id')
          .eq('auth_id', user.id)
          .single();

      final int customerId = customerRecord['id'];
      String? uploadedImageUrl;
      
      if (_selectedImageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';
        await Supabase.instance.client.storage
            .from('KGS')
            .uploadBinary(fileName, _selectedImageBytes!); 
        uploadedImageUrl = Supabase.instance.client.storage
            .from('KGS')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client.from('orders').insert({
        'customer_id': customerId, 
        'service_name': widget.preselectedTitle ?? _selectedService, 
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

  // Navigation
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
  void goToProfile() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())); }
  void goToOrders() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentOrdersScreen())); }
  void goToHome() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())); }
  void goToPlaceOrder() => Navigator.pop(context); 
  void goToServices() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen())); }
  void goToGallery() { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())); }

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.black),
          ),
          child: child!,
        );
      }
    );

    if (pickedDate == null || !mounted) return;
    setState(() {
      _selectedDeadline = pickedDate;
      _deadlineController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final String headerImage = widget.preselectedImageUrl ?? _serviceImages[_selectedService] ?? '';
    final String displayTitle = widget.preselectedTitle ?? _selectedService;

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text('Place Your Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfile, onSignout: signOut, onViewOrdersTap: goToOrders, 
        onHomeTap: goToHome, onPlaceOrderTap: goToPlaceOrder, onServiceTap: goToServices, onGalleryTap: goToGallery,
      ),
      body: Stack(
        children: [
          // --- 1. BACKGROUND HERO IMAGE ---
          if (headerImage.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(headerImage),
                    fit: BoxFit.cover,
                  ),
                ),
                // Dark gradient to make the white title readable
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.grey[50]!],
                    ),
                  ),
                ),
              ),
            ),

          // --- 2. FOREGROUND FORM CARD ---
          ListView(
            padding: const EdgeInsets.only(top: 150), // Push form down over the image
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      displayTitle,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    const Text('Fill in the details below to get started.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 24),

                    // SECTION: Service Category
                    const Text('Service Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedService,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _services.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  image: DecorationImage(image: NetworkImage(_serviceImages[s]!), fit: BoxFit.cover),
                                ),
                              ),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 15))),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedService = val);
                      },
                    ),
                    
                    const SizedBox(height: 20),

                    // SECTION: Project Details
                    const Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        hintText: 'Order Title / Brief Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number, 
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.numbers, color: Colors.grey),
                        labelText: 'Quantity',
                        // Beautiful Price Badge on the right
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _estimatedPrice,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) => setState(() {}), 
                    ),

                    const SizedBox(height: 24),

                    // SECTION: Deadline & Reference
                    const Text('Timeline & Reference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deadlineController,
                      readOnly: true,
                      onTap: _pickDeadline,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                        labelText: 'Order Deadline',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image Upload Area
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                          image: _selectedImageBytes != null
                              ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _selectedImageBytes == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
                                    child: const Icon(Icons.cloud_upload_outlined, size: 28, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Tap to upload a reference picture', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              )
                            : null, 
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _submitOrder,
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}