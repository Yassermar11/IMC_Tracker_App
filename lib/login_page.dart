import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'locale_notifier.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _errorMessage = '';
  bool _isSigningIn = false;
  bool _showPassword = false;

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _errorMessage = l10n.enterValidEmailToReset);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.passwordResetLinkSent} ${_emailController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(context, e.code));
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSigningIn = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(context, e.code);
      });
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  String _getErrorMessage(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'invalid-email': return l10n.invalidEmailError;
      case 'user-disabled': return l10n.userDisabledError;
      case 'user-not-found': return l10n.userNotFoundError;
      case 'wrong-password': return l10n.wrongPasswordError;
      default: return l10n.loginFailedError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle, style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          PopupMenuButton<Locale>(
            tooltip: l10n.changelanguage,
            icon: Icon(Icons.language, color: Colors.white),
            onSelected: (Locale locale) {
              localeNotifier.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                const PopupMenuItem(
                  value: Locale('fr'),
                  child: Text('Français'),
                ),
                const PopupMenuItem(
                  value: Locale('ar'),
                  child: Text('العربية'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('images/e.png', height: 320),
              SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.enterYourEmail;
                  if (!value.contains('@')) return l10n.enterValidEmail;
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.enterYourPassword;
                  if (value.length < 6) return l10n.passwordLengthError;
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSigningIn ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSigningIn
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.signInButton, style: TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: Text(
                    l10n.forgotPassword,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noAccountQuestion, style: TextStyle(
                    fontSize: 19,
                  )),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(l10n.registerButton, style: TextStyle(
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