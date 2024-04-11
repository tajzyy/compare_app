import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text,
                )
                    .then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  HomeScreen()),
                  );
                }).catchError((error) {
                  print(error);
                });
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text('Email'),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: ''),
            ),
            SizedBox(height: 16),
            Text('Password'),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(hintText: ''),
            ),
            SizedBox(height: 16),
            Text('Confirm Password'),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(hintText: ''),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_passwordController.text == _confirmPasswordController.text) {
                    // Sign up with Firebase Auth
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    )
                        .then((value) {
                      // Navigate to home screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }).catchError((error) {
                      print(error);
                    });
                  } else {
                    print('Passwords do not match');
                  }
                },
                child: Text('Sign Up'),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to login screen
                  Navigator.pop(context);
                },
                child: Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}