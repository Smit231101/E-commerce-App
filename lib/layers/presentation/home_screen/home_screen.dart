import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        centerTitle: false,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Home Screen - Products will go here'),
      ),
    );
  }
}