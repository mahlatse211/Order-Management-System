import 'package:flutter/material.dart';
import 'package:kgs/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import your home screen file

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = response.user?.id;
      if (userId != null) {
        await Supabase.instance.client.from('customers').insert({
          // 'user_id': userId,
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Join Katliey Graphics and get started',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign up', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
//nUMBER 2 OVERVIEW
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class RegistrationScreen extends StatefulWidget {
//   const RegistrationScreen({super.key});

//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   // 1. Define controllers for your text fields
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
  
//   bool _isLoading = false;

//   // 2. Function to save details to a specific Supabase table
//   Future<void> _saveDetails() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String name = _nameController.text.trim();
//       final String email = _emailController.text.trim();
//       final String phone = _phoneController.text.trim();
//       // final String password = _passwordController.text.trim();


//       // 3. Insert data into a specific table (e.g., named 'user_details')
//       await Supabase.instance.client.from('profiles').insert({
//         'full_name':name,
//         'email': email,
//         'phone_number':phone,
//         // 'password': password,
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Details saved successfully to Supabase!')),
//         );
//       }
//     } catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving details: $error')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     // Clean up controllers when the widget is disposed
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign Up Information')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Full Name'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _phoneController,
//               decoration: const InputDecoration(labelText: 'Phone Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 24),
//             _isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _saveDetails,
//                     child: const Text('Save Details'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }