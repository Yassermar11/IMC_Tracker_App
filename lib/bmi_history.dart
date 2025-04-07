import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BMIHistoryScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> _fetchBMIResults() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("User is not logged in");
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('bmiResults')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print("No BMI results found for user: ${user.uid}");
        return [];
      }

      print("Fetched ${snapshot.docs.length} BMI results");
      return snapshot.docs;
    } catch (e) {
      print("Error fetching BMI results: $e");
      return [];
    }
  }

  Future<void> _deleteResult(String documentId) async {
    try {
      await _firestore.collection('bmiResults').doc(documentId).delete();
      print("Deleted document: $documentId");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI History"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchBMIResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("FutureBuilder error: ${snapshot.error}");
            return Center(child: Text("Error loading data"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No BMI results found"));
          }

          var bmiResults = snapshot.data!;

          return ListView.builder(
            itemCount: bmiResults.length,
            itemBuilder: (context, index) {
              var doc = bmiResults[index];
              var data = doc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Delete"),
                        content: Text("Are you sure you want to delete this BMI record?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _deleteResult(doc.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("BMI record deleted")));
                },
                child: ListTile(
                  title: Text("BMI: ${data['bmi'].toStringAsFixed(2)}"),
                  subtitle: Text("Result: ${data['result']}"),
                  trailing: Text(
                    "${data['timestamp'].toDate().toString().substring(0, 16)}",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}