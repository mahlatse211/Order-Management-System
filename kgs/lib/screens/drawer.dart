import 'package:flutter/material.dart';
import 'package:kgs/components/list_tile.dart';
import 'package:kgs/screens/gallary_screens.dart'; // Make sure this path is correct for your project

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignout;
  final void Function()? onViewOrdersTap;
  final void Function()? onHomeTap;
  final void Function()? onPlaceOrderTap;
  final void Function()? onServiceTap;
  final void Function()? onGalleryTap; // New callback for Gallery

  const MyDrawer({
    super.key, 
    required this.onProfileTap, 
    required this.onSignout,
    required this.onViewOrdersTap,
    required this.onHomeTap,
    required this.onPlaceOrderTap,
    required this.onServiceTap,
    required this.onGalleryTap, // Initialize the new callback
 });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
         Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             // 1. HEADER
          const DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 64,
            ),
          ),

          // 2. TOP MENU ITEMS
          MyListTile(
            icon: Icons.home, 
            text: 'HOME',
            onTap: onHomeTap, // Calls the function passed from HomeScreen
          ),

          MyListTile(
            icon: Icons.person, 
            text: 'PROFILE',
            onTap: onProfileTap, // Calls the function passed from ProfilePage
          ),

          MyListTile(
            icon: Icons.shopping_cart, // Changed icon to make more sense
            text: 'PLACE ORDER',
            onTap: onPlaceOrderTap, // Calls the function passed from PlaceOrderScreen
          ),

          MyListTile(
            icon: Icons.outbond_rounded, 
            text: 'VIEW ORDER',
            onTap: onViewOrdersTap, // Calls the function passed from HomeScreen
          ),

          MyListTile(icon: Icons.info, text: 'SERVICE', onTap: onServiceTap,), // Calls the function passed from HomeScreen

          // Inside your MyDrawer build method, add this:
          MyListTile(
            icon: Icons.photo_library, 
            text: 'GALLERY',
            onTap: onGalleryTap, // Calls the function passed from HomeScreen
          ),
          ],
        ),

          // 3. THE SPACER
          // This expands to fill all remaining space, pushing the logout button down
          const Spacer(),

          // 4. BOTTOM MENU ITEM
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0), // A little padding at the bottom
            child: MyListTile(
              icon: Icons.logout, 
              text: 'LOG OUT',
              onTap: onSignout, // Calls the signOut function passed from ProfilePage
            ),
          ),
        ],
      ),
    );
  }
}