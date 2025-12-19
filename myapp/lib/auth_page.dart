import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_model.dart';
import 'l10n/app_localizations.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Formkey och controllers för e-post/lösen.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isBusy = false;
  String? _error;

  @override
  void dispose() {
    //  Städa controllers när pagen ändras.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    // closes keyboard and sets busy true.
    FocusScope.of(context).unfocus();
    setState(() {
      _isBusy = true;
      _error = null;
    });

    final auth = context.read<AuthModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await auth.signInWithEmail(email, password);
      } else {
        await auth.signUpWithEmail(email, password);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Inloggning misslyckades.';
      });
    } catch (e) {
      setState(() {
        _error = 'Något gick fel. Försök igen.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isBusy = true;
      _error = null;
    });

    final auth = context.read<AuthModel>();
    try {
      await auth.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Google-inloggningen misslyckades.';
      });
    } catch (e) {
      setState(() {
        _error = 'Google-inloggningen misslyckades.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final submitLabel = _isLogin ? l.login : l.signup;
    final toggleLabel = _isLogin ? l.toggleAuthModeToSignup : l.toggleAuthModeToLogin;

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      submitLabel,
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      // Email  with validation.
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l.email,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ange din e-postadress';
                        }
                        final email = value.trim();
                        if (!email.contains('@')) {
                          return 'Ogiltig e-postadress';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      // Password with validation.
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l.password,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ange ett lösenord';
                        }
                        if (value.length < 8) {
                          return 'Lösenordet måste vara minst 8 tecken';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isBusy ? null : _submit,
                      child: Text(submitLabel),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _isBusy ? null : _signInWithGoogle,
                      child: Text(l.loginWithGoogle),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isBusy ? null : _toggleMode,
                      child: Text(toggleLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
