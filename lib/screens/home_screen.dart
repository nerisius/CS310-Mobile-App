import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child:Column(
          children: [
            Text(
            "Welcome to Home Screen!"),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('log out')),
          ]
        ),
      ),
    );
  }
}
