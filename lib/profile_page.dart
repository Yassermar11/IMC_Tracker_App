import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'locale_notifier.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _nameController;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _currentUser = _auth.currentUser;
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      String username = '';

      if (_currentUser!.displayName != null && _currentUser!.displayName!.isNotEmpty) {
        username = _currentUser!.displayName!;
      } else {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          username = userDoc['username'] ?? '';
          await _currentUser!.updateDisplayName(username);
        }
      }

      setState(() {
        _nameController.text = username;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching username: $e");
      setState(() {
        _nameController.text = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      try {
        await _currentUser?.updateDisplayName(_nameController.text);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({'username': _nameController.text});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdatedSuccessfully),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (mounted) {
          Navigator.pop(context, _nameController.text);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.profileUpdateError} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _auth.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.signOutError} $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.profile),
          backgroundColor: Colors.green,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),

        actions: [
          PopupMenuButton<Locale>(
            tooltip: l10n.changelanguage,
            icon: Icon(Icons.language, color: Colors.white),
            onSelected: (Locale locale) {
              localeNotifier.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: Locale('en'),
                  child: Text("English"),
                ),
                PopupMenuItem(
                  value: Locale('fr'),
                  child: Text("Français"),
                ),
                PopupMenuItem(
                  value: Locale('ar'),
                  child: Text("العربية"),
                ),
              ];
            },
          ),
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () => _updateProfile(context),
            tooltip: l10n.save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue[50],
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0].toUpperCase()
                      : "U",
                  style: TextStyle(fontSize: 48, color: Colors.green[800]),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.displayName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.green),
                ),
                style: TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterName;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                child: Text(
                  '${l10n.yourEmail}: ${_currentUser?.email ?? l10n.notAvailable}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 160,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _signOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(100, 50),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    l10n.logOut,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}