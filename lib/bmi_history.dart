import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

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

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: Colors.green,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please sign in to view history'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In'),
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
        title: const Text('BMI History', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 50, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text('No BMI records found'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Calculate BMI'),
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
              final result = data['result'] as String;
              final weight = data['weight']?.toStringAsFixed(1) ?? 'N/A';
              final height = data['height']?.toStringAsFixed(1) ?? 'N/A';

              return Card(
                elevation: 2,
                color: _getCardColor(bmi),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const
                  //EdgeInsets.all(12),
                  EdgeInsets.only(top: 1, bottom: 1, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BMI: ${bmi.toStringAsFixed(1)}',
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
                    'Weight: $weight kg | Height: $height cm',
                    style: TextStyle(
                      color: _getTextColor(bmi),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Category: ${result.split('(')[0].trim()}',
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
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this BMI record?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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