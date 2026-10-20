import 'package:flutter/material.dart';
// // import 'new_order_screen.dart';
// // import 'orders_screen.dart';
// // import 'profile_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     const HomeFeedView(),
//     // const OrdersScreen(),
//     // const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // body: _screens[_currentIndex],
//       // bottomNavigationBar: BottomNavigationBar(
//       //   currentIndex: _currentIndex,
//       //   backgroundColor: Colors.black,
//       //   selectedItemColor: Colors.white,
//       //   unselectedItemColor: Colors.grey,
//       //   onTap: (index) => setState(() => _currentIndex = index),
//         // items: const [
//     //       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),[span_20](start_span)[span_20](end_span)[span_21](start_span)[span_21](end_span)
//     //       BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Orders'),[span_22](start_span)[span_22](end_span)[span_23](start_span)[span_23](end_span)
//     //       BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),[span_24](start_span)[span_24](end_span)[span_25](start_span)[span_25](end_span)
//     //     ],
//     //   ),
//     // );
  
// }

// class HomeFeedView extends StatelessWidget {
//   const HomeFeedView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         const Text('Welcome To Katliey Graphics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),[span_26](start_span)[span_26](end_span)
//         const Text('Build a brand people remember.', style: TextStyle(color: Colors.grey)),[span_27](start_span)[span_27](end_span)
//         const SizedBox(height: 20),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Need something amazing?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),[span_28](start_span)[span_28](end_span)
//                 //   Text("Let's bring your ideas to life", style: TextStyle(color: Colors.white70)),[span_29](start_span)[span_29](end_span)
//                 // ],
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen())),
//                 child: const Text('New Order', style: TextStyle(color: Colors.white)),[span_30](start_span)[span_30](end_span)
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

//Gemini Suggestion
import 'package:kgs/models/serviceItem.dart';
import 'package:kgs/screens/drawer.dart';
import 'package:kgs/screens/login.dart';
import 'package:kgs/screens/ordersScreen.dart';
import 'package:kgs/screens/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'newOrder.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<ServiceItem> services = [
    ServiceItem(
      title: 'Logo Design',
      price: 'From R300',
      imagePath: 'assets/Logo2.jpeg', 
     
    ),
    ServiceItem(
      title: 'Event Poster',
      price: 'From R800',
      imagePath: 'assets/Event poster.jpeg', 
    ),
    ServiceItem(
      title: 'Flyer',
      price: 'From R500',
      imagePath: 'assets/Flyer.jpeg', // Replace with your asset path
    ),
    ServiceItem(
      title: 'Brand Design',
      price: 'From R800',
      imagePath: 'assets/Brand Design.jpeg', // Replace with your asset path
    ),
  ];

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
    // If we are already on profile page, just close the drawer
    Navigator.pop(context); 
    // go to profile page
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),)); // Navigate to profile page
  }

  void goToOrders() {
    // If we are already on orders page, just close the drawer
    Navigator.pop(context);
    // go to orders page
    Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentOrdersScreen(),)); // Navigate to orders page
  }
  void goToHome() {
    // If we are already on home page, just close the drawer
    Navigator.pop(context);
    // go to home page
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen(),)); // Navigate to home page
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katliey Graphics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfile,
        onSignout: signOut,
        onViewOrdersTap: goToOrders, // Navigate to orders page
        onHomeTap: goToHome, // Navigate to home page
        ),

      body: SafeArea(
        child: Column(
          children: [
            // Top Black Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Icon
                 
                  // Greeting
                 
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Rounded White Content Body
            Expanded(
              child: Container(
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
                      children: [
                        // Services Grid
                        GridView.builder(
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service Image Card
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: AssetImage(service.imagePath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Service Title
                                Text(
                                  service.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                // Service Price
                                Text(
                                  service.price,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // "See More Services" Divider Section
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[600], thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'see more services',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[600], thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Promo Banner ("Need something amazing?")
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Need something amazing?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Let's bring your ideas to life",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewOrderScreen(),
      ),
    );
  },
  child: const Text(
    'New Order',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (index) {
          
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

