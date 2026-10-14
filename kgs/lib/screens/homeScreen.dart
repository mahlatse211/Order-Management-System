// import 'package:flutter/material.dart';
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