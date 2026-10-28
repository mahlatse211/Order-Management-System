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
  
  String _userName = 'Loading...';
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

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
        _userName = 'User'; 
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

  void goToHome() => Navigator.pop(context); 

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
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: const Text('Katliey Graphics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: Welcome & Avatar ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        if (_isLoadingName)
                          const SizedBox(height: 28, width: 100, child: LinearProgressIndicator())
                        else
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.black
                            ),
                          ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFF5F5F5),
                      child: Icon(Icons.person, color: Colors.black54),
                    )
                  ],
                ),
                
                const SizedBox(height: 30),

                // --- SECTION TITLE ---
                const Text(
                  'Explore Our Work',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // --- STAGGERED PORTFOLIO GRID (With Skeleton Loading) ---
                const HomeFeedView(),
                
                const SizedBox(height: 20),

                // --- SEE MORE SERVICES ---
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen()));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'See all services', 
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14)
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- PREMIUM PROMO BANNER ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFFF4081)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Need something amazing?', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Let's bring your ideas to life.", 
                              style: TextStyle(color: Colors.white70, fontSize: 13)
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen()));
                        },
                        child: const Text('Start Order', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HOME FEED VIEW (Handles its own Loading State) ---
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchHomeServices(),
      builder: (context, snapshot) {
        
        // --- 1. SKELETON LOADING STATE ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column Skeleton
              Expanded(
                child: Column(
                  children: [
                    _buildSkeletonCard(height: 220),
                    _buildSkeletonCard(height: 160),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right Column Skeleton
              Expanded(
                child: Column(
                  children: [
                    _buildSkeletonCard(height: 160),
                    _buildSkeletonCard(height: 220),
                  ],
                ),
              ),
            ],
          );
        }

        // --- 2. ERROR STATE ---
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error loading services', style: TextStyle(color: Colors.red[400])),
            ),
          );
        }

        // --- 3. EMPTY STATE ---
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No services uploaded yet.', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        final services = snapshot.data!;

        // Split into two columns for the staggered effect
        final leftColumn = services.where((e) => services.indexOf(e) % 2 == 0).toList();
        final rightColumn = services.where((e) => services.indexOf(e) % 2 != 0).toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              child: Column(
                children: leftColumn.map((service) => _buildStaggeredCard(service, true)).toList(),
              ),
            ),
            const SizedBox(width: 16),
            // Right Column
            Expanded(
              child: Column(
                children: rightColumn.map((service) => _buildStaggeredCard(service, false)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- HELPER: Skeleton Card ---
  Widget _buildSkeletonCard({required double height}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Skeleton grey background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]), // Subtle icon
      ),
    );
  }

  // --- HELPER: Builds the Image Card with Gradient Overlay ---
  Widget _buildStaggeredCard(Map<String, dynamic> service, bool isTall) {
    final title = service['title'] ?? 'Service';
    final price = service['price'] ?? 'R0';
    final category = service['category'] ?? 'General';
    final imageUrl = service['image_url'];

    return GestureDetector(
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
        margin: const EdgeInsets.only(bottom: 16),
        height: isTall ? 220 : 160, // Staggered heights
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
          color: Colors.grey[300], // Fallback color
          image: imageUrl != null && imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imageUrl), 
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // Dark gradient at the bottom for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From $price', 
                      style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // If there's no image, show an icon in the center
            if (imageUrl == null || imageUrl.isEmpty)
              const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
          ],
        ),
      ),
    );
  }
}