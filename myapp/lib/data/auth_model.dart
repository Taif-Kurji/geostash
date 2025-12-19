import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._auth) {
    _user = _auth.currentUser;
    // Lyssna på auth-state och notifiera UI vid ändring.
    _subscription = _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  static Future<void>? _googleInit;

  User? get user => _user;
  bool get isSignedIn => _user != null;

  Future<UserCredential> signUpWithEmail(String email, String password) {
    // register email and pass.
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithEmail(String email, String password) {
    // Login email and pass.
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    //  sign out and close goggle session.
    await _auth.signOut();
    if (!kIsWeb) {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
    await signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _auth.signInWithPopup(provider);
    }

    await _ensureGoogleInitialized();
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Inloggningen avbröts.',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.description ?? 'Google-inloggningen misslyckades.',
      );
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'google-id-token-missing',
        message: 'Kunde inte läsa ID-token från Google.',
      );
    }
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> _ensureGoogleInitialized() {
    _googleInit ??= GoogleSignIn.instance.initialize();
    return _googleInit!;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
