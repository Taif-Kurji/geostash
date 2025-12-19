
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_page.dart';
import 'data/auth_model.dart';
import 'data/cache_model.dart';
import 'data/find_model.dart';
import 'data/group_model.dart';
import 'data/settings_model.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'l10n/app_localizations.dart';

//   Startar Firebase och appen.
Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  //   Koppla upp Firebase 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //   Kör rotwidgeten.
  runApp(const GeoStashApp());
}

class GeoStashApp extends StatelessWidget {
  const GeoStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    //   Globala providers för tema/språk och auth.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthModel(FirebaseAuth.instance),
        ),
      ],
      child: Consumer2<SettingsModel, AuthModel>(
        builder: (context, settings, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          // Titel från l10n.
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          //   Ljust tema.
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
            useMaterial3: true,
          ),
          // * Mörkt tema.
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          //   Använd sparat tema och språk.
          themeMode: settings.themeMode,
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuthGate(),
        ),
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
          //   Ingen inloggning → visa auth-sidan.
          return const AuthPage();
        }

        final user = auth.user!;
        //   GroupModel skapas efter inloggning för rätt användare.

        return ChangeNotifierProvider<GroupModel>(
          key: ValueKey('groups_${user.uid}'),
          create: (_) => GroupModel(FirebaseFirestore.instance, user.uid),
          child: HomeShell(userId: user.uid),
        );
      },
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupModel>(
      builder: (context, groups, _) {
        final groupId = groups.selectedGroupId;
        if (groups.isLoading) {
          //   Visar spinner medan memberships laddas.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (groups.errorMessage != null) {
          //   Visar feltext om något gick fel.
          return Scaffold(
            body: Center(child: Text(groups.errorMessage!)),
          );
        }
        if (groupId == null) return const HomePage();

        
        return MultiProvider(
          key: ValueKey('models_$groupId'),
          providers: [
            ChangeNotifierProvider(
              create: (_) => CacheModel(FirebaseFirestore.instance, userId, groupId),
            ),
            ChangeNotifierProvider(
              create: (_) => FindModel(FirebaseFirestore.instance, userId, groupId),
            ),
          ],
          child: KeyedSubtree(
            key: ValueKey('home_for_group_$groupId'),
            child: const HomePage(),
          ),
        );
      },
    );
  }
}
