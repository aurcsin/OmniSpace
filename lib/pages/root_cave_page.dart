import 'package:flutter/material.dart';

class RootCavePage extends StatelessWidget {
  const RootCavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Root Cave / Underground')),
      body: const Center(child: Text('Root Cave / Underground Page')),
    );
  }
}
