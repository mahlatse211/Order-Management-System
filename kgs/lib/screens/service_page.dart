import 'package:flutter/material.dart';
import 'package:kgs/screens/newOrder.dart'; 
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/ordersScreen.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  // 1. We now combine the image URL directly into the service data
  final List<Map<String, dynamic>> services = const [
    {
      'name': 'Logo Design', 
      'desc': 'Custom logos for your brand',
      'image': 'https://images.unsplash.com/photo-1626785774573-4b799315345d?q=80&w=600&auto=format&fit=crop', 
    },
    {
      'name': 'Brand Design', 
      'desc': 'Complete brand identity packages',
      'image': 'https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=600&auto=format&fit=crop', 
    },
    {
      'name': 'Website Design', 
      'desc': 'Modern and responsive websites',
      'image': 'https://images.unsplash.com/photo-1547658719-da2b51169166?q=80&w=600&auto=format&fit=crop', 
    },
    {
      'name': 'Event Promotion', 
      'desc': 'Posters, flyers, and digital invites',
      'image': 'https://images.unsplash.com/photo-1558655146-d09347e92766?q=80&w=600&auto=format&fit=crop', 
    },
    {
      'name': 'Print Design', 
      'desc': 'Business cards, brochures, and banners',
      'image': 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Digital Design', 
      'desc': 'Social media graphics and digital ads',
      'image': 'https://images.unsplash.com/photo-1572044162444-ad60f128bdea?q=80&w=600&auto=format&fit=crop',
    },
  ];

  void goToProfile(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())); 
  }

  void goToOrders(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentOrdersScreen())); 
  }

  void goToHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())); 
  }
  void goToPlaceOrder(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen())); 
  }
  

  Future<void> signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfile(context),
        onSignout: () => signOut(context),
        onViewOrdersTap: () => goToOrders(context), 
        onHomeTap: () => goToHome(context), 
        onPlaceOrderTap: () => goToPlaceOrder(context), 
        onServiceTap: () => Navigator.pop(context),
      ),
      // 2. Use a simple ListView instead of a complex CustomScrollView
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias, // Ensures the image respects the card's rounded corners
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewOrderScreen(
                      preselectedService: service['name'], 
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: 120, // Fixed height for the card
                child: Row(
                  children: [
                    // --- LEFT SIDE: IMAGE ---
                    SizedBox(
                      width: 120, // Square aspect ratio for the image
                      height: double.infinity,
                      child: Image.network(
                        service['image'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    
                    // --- RIGHT SIDE: TEXT ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              service['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              service['desc'],
                              style: TextStyle(
                                fontSize: 13, 
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // --- FAR RIGHT: ARROW ---
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }}