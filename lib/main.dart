import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const EmojimiaApp());
}

class EmojimiaApp extends StatelessWidget {
  const EmojimiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emojimia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
