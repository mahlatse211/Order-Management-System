import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/homeScreen.dart';
import 'package:kgs/screens/login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('KATLIEY GRAPHIC SOLUTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),[cite: 5]
                const SizedBox(height: 20),
                const Text('Welcome Back!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),[cite: 5]
                const Text('Log in to continue to your account', style: TextStyle(color: Colors.grey)),[cite: 5]
//                 const SizedBox(height: 30),
//                 TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email address')),[cite: 5]
//                 const SizedBox(height: 15),
//                 TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),[cite: 5]
//                 const SizedBox(height: 25),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(15)),
//                   onPressed: _isLoading ? null : _login,
//                   child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Log in', style: TextStyle(color: Colors.white)),[cite: 5]
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
//                   },
//                   child: const Text('Don\'t have an account? Sign up'),[cite: 5]
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }