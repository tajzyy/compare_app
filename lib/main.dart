import 'package:flutter/material.dart';
import './login_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:compare_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(144,170,122,1),
          background: const Color.fromRGBO(177,205,214,1)),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
