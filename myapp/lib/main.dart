import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "my app",
    theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.red,
      ),
     home: StartPage(title: "simple button"));
  }
  }


class StartPage extends StatefulWidget {
  final dynamic title;
  const StartPage({super.key, required this.title}); 

  

  @override
  State<StartPage> createState() => _StartPageState();
}


class _StartPageState extends State<StartPage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              'Button has been pressed: $_counter times',
              style: Theme.of(context).textTheme.headlineMedium
            ),
            
            
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('press me'),
            ),
          ],
        ),
      ),
    );
  }
}
