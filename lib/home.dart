import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:imc_secured/profile_page.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'bmi_calculator.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController controlWeight = TextEditingController();
  final TextEditingController controlHeight = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _info = "";
  double _bmi = 0.0;
  String _userName = "";
  bool _showGauge = false; // Changed to false initially

  @override
  void initState() {
    super.initState();
    _getUserData();
    _checkAuth();
  }

  void _checkAuth() {
    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/login');
      });
    }
  }

  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // First try to get displayName from Auth
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          setState(() {
            _userName = user.displayName!;
          });
        } else {
          // Fall back to Firestore username
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final userData = userDoc.data() as Map<String, dynamic>;
            setState(() {
              _userName = userData['username'] ?? 'User';
            });
            // Update auth displayName for future use
            await user.updateDisplayName(userData['username']);
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          _userName = "User";
        });
      }
    }
  }
  void _navigateToProfile() async {
    final updatedName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );

    if (updatedName != null) {
      setState(() {
        _userName = updatedName;
      });
    }
  }

  Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24.9) return Colors.green;
    if (bmi < 29.9) return Colors.yellow;
    if (bmi < 34.9) return Colors.orange;
    if (bmi < 39.9) return Colors.purple;
    return Colors.red;
  }

  Future<void> _saveBMI() async {
    if (_bmi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please calculate BMI first!')),
      );
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('bmiResults').add({
          'userId': user.uid,
          'bmi': _bmi,
          'result': _info,
          'timestamp': DateTime.now(),
          'weight': double.tryParse(controlWeight.text),
          'height': double.tryParse(controlHeight.text),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('BMI saved successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save BMI: $e')),
      );
    }
  }
  void _resetFields() {
    controlWeight.clear();
    controlHeight.clear();
    setState(() {
      _info = "";
      _bmi = 0.0;
      _showGauge = false;
      _formKey.currentState?.reset();
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    double weight = double.parse(controlWeight.text);
    double height = double.parse(controlHeight.text) / 100;
    double imc = BMICalculator.calculateBMI(weight, height);
    String result = BMICalculator.getBMIResult(imc);

    setState(() {
      _info = result;
      _bmi = imc;
      _showGauge = true; // Show gauge only after calculation
    });
  }

  Widget _buildBMIGauge() {
    return Container(
      height: 250,
      margin: EdgeInsets.symmetric(vertical: 20),
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 10,
            maximum: 50,
            ranges: <GaugeRange>[
              GaugeRange(startValue: 0.0, endValue: 18.5, color: Colors.blue, label: 'Underweight'),
              GaugeRange(startValue: 18.5, endValue: 24.9, color: Colors.green, label: 'Normal'),
              GaugeRange(startValue: 25.0, endValue: 29.9, color: Colors.yellow, label: 'Overweight'),
              GaugeRange(startValue: 30.0, endValue: 34.9, color: Colors.orange, label: 'Obesity I'),
              GaugeRange(startValue: 35.0, endValue: 39.9, color: Colors.purple, label: 'Obesity II'),
              GaugeRange(startValue: 40.0, endValue: 50.0, color: Colors.red, label: 'Obesity III'),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: _bmi,
                enableAnimation: true,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  _bmi.toStringAsFixed(1),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                positionFactor: 0.8,
                angle: 90,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("BMI CALCULATOR", style: TextStyle(
            fontFamily: "Segoe UI",
            color:Colors.white,
            fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),

        actions: [
          Tooltip(
            message: "View History",
            child: IconButton(
              icon: Icon(Icons.history),
              onPressed: () => context.push('/history'),
            ),
          ),
          Tooltip(
            message: "Reset",
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetFields,
            ),
          ),
          Tooltip(
            message: "Profile",
            child: IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U', style: TextStyle(fontSize: 20, color: Colors.green[800])),
              ),
              onPressed: _navigateToProfile,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Text(
                  'Welcome back, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(Icons.person, size: 120.0, color: Colors.green),
              _buildInputField(controlWeight, "Weight (Kg)"),
              _buildInputField(controlHeight, "Height (cm)"),
              _buildActionButton("Calculate", Colors.green, _calculate, "Calculate BMI"),
              _buildActionButton("Save Result", Colors.blue, _saveBMI, "Save BMI Result"),
              if (_info.isNotEmpty) Text(
                _info,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: getBMIColor(_bmi),
                  fontSize: 25.0,
                  fontFamily: "Segoe UI",
                ),
              ),
              if (_showGauge) _buildBMIGauge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green, fontFamily: "Segoe UI"),
      ),
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.green, fontSize: 25.0, fontFamily: "Segoe UI"),
      validator: (value) => value?.isEmpty ?? true ? "Please enter your $label" : null,
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed, String tooltip) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: SizedBox(
        height: 50.0,
        child: Tooltip(
          message: tooltip,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              textStyle: TextStyle(fontSize: 25.0, fontFamily: "Segoe UI"),
            ),
            child: Text(text, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}