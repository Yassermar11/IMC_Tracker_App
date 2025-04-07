import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'bmi_calculator.dart';
import 'bmi_history.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController controlWeight = TextEditingController();
  final TextEditingController controlHeight = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _info = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _bmi = 0.0;

  Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.orange;
    } else if (bmi >= 18.5 && bmi < 25) {
      return Colors.green;
    } else if (bmi >= 25 && bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _resetFields() {
    controlHeight.text = "";
    controlWeight.text = "";
    setState(() {
      _info = "";
      _bmi = 0.0;
    });
  }

  void _calculate() async {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(controlWeight.text);
      double height = double.parse(controlHeight.text) / 100;
      double imc = BMICalculator.calculateBMI(weight, height);
      String result = BMICalculator.getBMIResult(imc);

      setState(() {
        _info = result;
        _bmi = imc;
      });

      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('bmiResults').add({
          'userId': user.uid,
          'bmi': imc,
          'result': result,
          'timestamp': DateTime.now(),
        });
      }
    }
  }

  void _signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
      if (mounted) {
        context.pushReplacement('/sign-in');
      }
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Widget _buildBMIGauge() {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 10,
          maximum: 50,
          ranges: <GaugeRange>[
            GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue, label: 'Underweight'),
            GaugeRange(startValue: 18.5, endValue: 24.9, color: Colors.green, label: 'Normal'),
            GaugeRange(startValue: 24.9, endValue: 29.9, color: Colors.yellow, label: 'Overweight'),
            GaugeRange(startValue: 29.9, endValue: 34.9, color: Colors.orange, label: 'Obesity I'),
            GaugeRange(startValue: 34.9, endValue: 39.9, color: Colors.red, label: 'Obesity II'),
            GaugeRange(startValue: 40, endValue: 50, color: Colors.purple, label: 'Obesity III'),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(value: _bmi, enableAnimation: true),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                _bmi > 0 ? "${_bmi.toStringAsFixed(1)}" : "",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              positionFactor: 0.8,
              angle: 90,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/sign-in');
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BMI CALCULATOR",
          style: TextStyle(fontFamily: "Segoe UI"),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          Tooltip(
            message: "Reset",
            child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetFields,
          ),
          ),
          Tooltip(
            message: "Logout",
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: _signOut,
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
              Icon(
                Icons.person,
                size: 120.0,
                color: Colors.green,
              ),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Weight (Kg)",
                  labelStyle: TextStyle(
                    color: Colors.green,
                    fontFamily: "Segoe UI",
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 25.0,
                  fontFamily: "Segoe UI",
                ),
                controller: controlWeight,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insert your weight!";
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  labelStyle: TextStyle(
                    color: Colors.green,
                    fontFamily: "Segoe UI",
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 25.0,
                  fontFamily: "Segoe UI",
                ),
                controller: controlHeight,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insert your height!";
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: SizedBox(
                  height: 50.0,
                  child: Tooltip(
                    message: "Calcule BMI",
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      textStyle: TextStyle(
                        fontSize: 25.0,
                        fontFamily: "Segoe UI",
                      ),
                    ),
                    child: Text(
                      "Calculate",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ),
                ),
              ),
              Text(
                _info,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: getBMIColor(_bmi),
                  fontSize: 25.0,
                  fontFamily: "Segoe UI",
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                child: _buildBMIGauge(),
              ),

              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: SizedBox(
                  height: 50.0,
                  child: Tooltip(
                    message: "Calcule BMI ",
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/history');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontSize: 25.0,
                          fontFamily: "Segoe UI",
                        ),
                      ),
                      child: Text(
                        "View History",
                        style: TextStyle(color: Colors.black),
                      ),
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