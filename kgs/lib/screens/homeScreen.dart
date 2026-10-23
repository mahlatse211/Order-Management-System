import 'package:flutter/material.dart';
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/gallary_screens.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/ordersScreen.dart';
import 'package:kgs/screens/profile.dart';
import 'package:kgs/screens/service_page.dart' show ServicesScreen;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'newOrder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // 1. Variables to hold the user's name and loading state
  String _userName = 'Loading...';
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // 2. Fetch the name from Supabase
  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _userName = 'Guest';
        _isLoadingName = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('customers')
          .select('full_name')
          .eq('auth_id', user.id)
          .single();

      setState(() {
        _userName = response['full_name'] ?? 'User';
        _isLoadingName = false;
      });
    } catch (e) {
      debugPrint('Error fetching name: $e');
      setState(() {
        _userName = 'User'; // Fallback if not found
        _isLoadingName = false;
      });
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
  }

  void goToPlaceOrder() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen())); 
  }

  void goToService() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen())); 
  }
  void goToGallery() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(child: const Text('Katliey Graphics', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
      body: Container(
        color: Colors.black, // Dark background behind the white card
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Display the fetched Name
                  if (_isLoadingName)
                    const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                  else
                    Center(
                      child: Text(
                        'Hello, $_userName!', // Greeting with the fetched name
                        style: const TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),

                  // 4. The Portfolio Grid
                  const HomeFeedView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- HOME FEED VIEW (Portfolio Grid) ---
class HomeFeedView extends StatefulWidget {
  const HomeFeedView({super.key});

  @override
  State<HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<HomeFeedView> {
  Future<List<Map<String, dynamic>>> _fetchHomeServices() async {
    final response = await Supabase.instance.client
        .from('portfolio')
        .select()
        .order('created_at', ascending: false) 
        .limit(4); 
        
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchHomeServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading services', style: TextStyle(color: Colors.red[400])));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No services uploaded yet.'));
            }

            final services = snapshot.data!;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                final title = service['title'] ?? 'Service';
                final price = service['price'] ?? 'R0';
                final category = service['category'] ?? 'General';
                final imageUrl = service['image_url'];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewOrderScreen(preselectedService: category),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            image: imageUrl != null && imageUrl.isNotEmpty
                                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                                : null, 
                          ),
                          child: imageUrl == null || imageUrl.isEmpty
                              ? const Icon(Icons.image, color: Colors.grey, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('From $price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // See More Services
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen()));
          },
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[600], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('see more services', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.underline)),
              ),
              Expanded(child: Divider(color: Colors.grey[600], thickness: 1)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Promo Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFFF5252), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Need something amazing?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 4),
                    Text("Let's bring your ideas to life", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen()));
                },
                child: const Text('New Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}