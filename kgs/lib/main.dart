// import 'package:flutter/material.dart';
// //import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'viewmodels/order_viewmodel.dart';
// import 'screens/login.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://wypidtddvljsxldhbhab.supabase.co',
//     anonKey: 'sb_publishable_xojKIstUVBMiXlqeGCw6Mg_3wUI4oNp',
//   );

//    runApp(const KatliApp());
// }

// class KatliApp extends StatelessWidget {
//   const KatliApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Katliey Graphic Solution',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: Colors.black,
//         scaffoldBackgroundColor: Colors.white,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
//       ),
//        home: const LoginScreen(), //
//     );
//   }
// }



//ChatGPT Suggestion
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kgs/screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://wypidtddvljsxldhbhab.supabase.co',
      publishableKey: 'sb_publishable_xojKIstUVBMiXlqeGCw6Mg_3wUI4oNp'
    );

    runApp(const KatliApp());
  } catch (e, stackTrace) {
    debugPrint('SUPABASE INITIALIZATION ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Supabase initialization failed:\n\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KatliApp extends StatelessWidget {
  const KatliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katliey Graphic Solution',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}