import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
      ],
      child: MaterialApp(
        title: 'Katliey Graphics',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: const LoginView(),
      ),
    );
  }
}