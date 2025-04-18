import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'locale_notifier.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _error;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      await credential.user?.updateDisplayName(_usernameController.text.trim());
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = _getErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(BuildContext context, dynamic e) {
    final l10n = AppLocalizations.of(context)!;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use': return l10n.emailInUseError;
        case 'invalid-email': return l10n.invalidEmailError;
        case 'weak-password': return l10n.weakPasswordError;
        default: return '${l10n.registrationFailed}: ${e.message}';
      }
    }
    return l10n.registrationFailedGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(l10n.registerTitle, style: TextStyle( // Changed from loginTitle to registerTitle
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          )),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: Directionality(
          textDirection: TextDirection.ltr,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: PopupMenuButton<Locale>(
              tooltip: l10n.changelanguage,
              icon: Icon(Icons.language, color: Colors.white),
              onSelected: (Locale locale) {
                localeNotifier.setLocale(locale);
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: Locale('en'),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('English'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: Locale('fr'),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('Français'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: Locale('ar'),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('العربية'),
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.asset('images/e.png', height: 320),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.usernameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? l10n.enterUsername : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) =>
                value == null || !value.contains('@')
                    ? l10n.enterValidEmail : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) => value != null && value.length < 6
                    ? l10n.passwordLengthError : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: l10n.confirmPasswordLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
                obscureText: !_showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.confirmPasswordError;
                  if (value != _passwordController.text) return l10n.passwordsDoNotMatch;
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.registerButton, style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.haveAccountQuestion, style: TextStyle(
                    fontSize: 19,
                  )),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(l10n.loginButton, style: TextStyle(
                      color: Colors.green,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}