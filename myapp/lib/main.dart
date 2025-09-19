
import 'package:flutter/material.dart';
import 'intro_page.dart';

void main() => runApp(const GeoStashApp());

class GeoStashApp extends StatelessWidget {
  const GeoStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'GeoStash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const IntroPage(),
    );
  }
}
