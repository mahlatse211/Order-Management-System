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
  
  Future<List<Map<String, dynamic>>> _fetchPortfolio() async {
    final response = await Supabase.instance.client
        .from('portfolio')
        .select()
        .order('created_at', ascending: false); 
        
    return List<Map<String, dynamic>>.from(response);
  }

  // Navigation Methods
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
  
  void goToGallery(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())); 
  }
  
  void goToService(BuildContext context) {
    Navigator.pop(context); 
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
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(
        title: const Text('Our Services', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), 
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
        onGalleryTap: () => goToGallery(context),
      ),
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
              
              final title = item['title'] ?? 'Service';
              final category = item['category'] ?? 'General';
              final imageUrl = item['image_url'] ?? ''; 
              final price = item['price']?.toString() ?? '0';

              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _HoverScaleCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewOrderScreen(
                          preselectedService: category,
                          preselectedImageUrl: imageUrl, 
                          preselectedTitle: title,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 160, // Slightly taller for the new layout
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // --- 1. BACKGROUND IMAGE ---
                          imageUrl.isNotEmpty 
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator()),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.grey, size: 40),
                              ),
                          
                          // --- 2. GRADIENT OVERLAY ---
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),

                          // --- 3. TEXT CONTENT ---
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    category.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Title
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 22,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                
                                // Price Row with Arrow
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'From $price',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.greenAccent, // Brighter green
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

// --- NEW WIDGET: Adds a subtle scale animation when tapped ---
class _HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverScaleCard({required this.child, required this.onTap});

  @override
  State<_HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<_HoverScaleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0, // Shrinks slightly when pressed
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}