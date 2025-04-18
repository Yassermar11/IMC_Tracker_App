import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'bmi_calculator.dart';
import 'locale_notifier.dart';

class BMIHistoryScreen extends StatelessWidget {
  Color _getCardColor(double bmi) {
    if (bmi < 18.5) return Colors.lightBlue[100]!;
    if (bmi < 24.9) return Colors.green[100]!;
    if (bmi < 29.9) return Colors.yellow[100]!;
    if (bmi < 34.9) return Colors.orange[100]!;
    if (bmi < 39.9) return Colors.purple[100]!;
    return Colors.red[100]!;
  }

  Color _getTextColor(double bmi) {
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            Consumer<LocaleNotifier>(
              builder: (context, localeNotifier, child) {
                final l10n = AppLocalizations.of(context)!;
                return Tooltip(
                  message: l10n.changelanguage,  // Your custom tooltip
                  child: PopupMenuButton<Locale>(
                    // Disable default tooltip completely
                    tooltip: '',  // <- Critical to override default
                    icon: const Icon(Icons.language, color: Colors.white),
                    onSelected: (locale) => localeNotifier.setLocale(locale),
                    itemBuilder: (context) => [
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
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.signInToViewHistory),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.signIn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bmiHistoryTitle, style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<Locale>(
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
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bmiResults')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorLoadingData));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 50, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(l10n.noRecordsFound, style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.calculateBmi, style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final bmi = (data['bmi'] as num).toDouble();
              final resultKey = data['resultKey'] as String?;
              if (resultKey == null) return Container();
              final result = BMICalculator.getBMIResult(context, bmi, resultKey);
              final weight = data['weight']?.toStringAsFixed(1) ?? l10n.notAvailable;
              final height = data['height']?.toStringAsFixed(1) ?? l10n.notAvailable;

              return Card(
                elevation: 2,
                color: _getCardColor(bmi),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.only(top: 1, bottom: 1, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.bmiLabel}: ${bmi.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: _getTextColor(bmi),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(context, doc.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${l10n.categoryLabel}: ${result.split('(')[0].trim()}',
                        style: TextStyle(
                          color: _getTextColor(bmi),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${l10n.categoryLabel}: ${result.split('(')[0].trim()}',
                        style: TextStyle(
                          color: _getTextColor(bmi),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp),
                        style: TextStyle(
                          color: _getTextColor(bmi),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String docId) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteRecordTitle),
          content: Text(l10n.deleteRecordConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteRecord(docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('bmiResults').doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}