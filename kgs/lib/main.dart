import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'viewmodels/order_viewmodel.dart';
// import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wypidtddvljsxldhbhab.supabase.co',
    anonKey: 'sb_publishable_xojKIstUVBMiXlqeGCw6Mg_3wUI4oNp',
  );

   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure to return a widget here
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}