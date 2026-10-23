import 'package:flutter/material.dart';
import 'package:kgs/screens/gallary_screens.dart';
import 'package:kgs/screens/newOrder.dart'; 
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/ordersScreen.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  
  // 1. Fetch data from the 'portfolio' table that your ASP.NET app writes to
  Future<List<Map<String, dynamic>>> _fetchPortfolio() async {
    final response = await Supabase.instance.client
        .from('portfolio')
        .select()
        .order('created_at', ascending: false); // Newest first
        
    return List<Map<String, dynamic>>.from(response);
  }

  // Navigation methods
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
  void goToGallery() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())); 
  }
  
  void goToService(BuildContext context) {
    Navigator.pop(context); // Already here
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
        actions: [
          // Add a refresh button so customers can pull the latest ASP.NET updates
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Triggers the FutureBuilder to re-fetch
            },
          )
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfile(context),
        onSignout: () => signOut(context),
        onViewOrdersTap: () => goToOrders(context), 
        onHomeTap: () => goToHome(context), 
        onPlaceOrderTap: () => goToPlaceOrder(context), 
        onServiceTap: () => goToService(context),
        onGalleryTap: goToGallery,
      ),
      // 2. FutureBuilder to handle the loading of ASP.NET data
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPortfolio(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading portfolio: ${snapshot.error}', 
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No services available at the moment.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          final portfolioItems = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            itemCount: portfolioItems.length,
            itemBuilder: (context, index) {
              final item = portfolioItems[index];
              
              // 3. Extract data matching your exact Supabase columns
              final title = item['title'] ?? 'Service';
              final category = item['category'] ?? 'General';
              final imageUrl = item['image_url'] ?? ''; 
              final price = item['price']?.toString() ?? '0';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 20.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias, 
                child: InkWell(
                  onTap: () {
                    // Pass the 'category' (e.g., Logo Design) to the NewOrderScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewOrderScreen(preselectedService: category),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 130, 
                    child: Row(
                      children: [
                        // --- LEFT SIDE: IMAGE FROM ASP.NET ---
                        SizedBox(
                          width: 130, 
                          height: double.infinity,
                          child: imageUrl.isNotEmpty 
                            ? Image.network(
                                imageUrl,
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
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.grey, size: 40),
                              ),
                        ),
                        
                        // --- RIGHT SIDE: TEXT & PRICE ---
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category, // Showing the category instead of description
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'From $price',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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