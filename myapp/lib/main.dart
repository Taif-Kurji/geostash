
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_page.dart';
import 'data/auth_model.dart';
import 'data/cache_model.dart';
import 'firebase_options.dart';
import 'intro_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GeoStashApp());
}

class GeoStashApp extends StatelessWidget {
  const GeoStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthModel(FirebaseAuth.instance),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GeoStash',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, auth, _) {
        if (!auth.isSignedIn) {
          return const AuthPage();
        }

        final user = auth.user!;
        return ChangeNotifierProvider<CacheModel>(
          key: ValueKey(user.uid),
          create: (_) => CacheModel(FirebaseFirestore.instance, user.uid),
          child: const IntroPage(),
        );
      },
    );
  }
}
