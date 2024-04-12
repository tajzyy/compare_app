import 'package:flutter/material.dart';
import 'home_tab.dart';

class TestTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Tab'),
      ),
      body: HomeTab(), // Use the HomeTab widget here to test
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TestTab(),
  ));
}