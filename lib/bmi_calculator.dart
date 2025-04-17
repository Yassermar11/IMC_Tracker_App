import 'dart:ui';

import 'package:flutter/material.dart';

class BMICalculator {
  static double calculateBMI(double weight, double height) {
    return weight / (height * height);
  }

  static String getBMIResult(double bmi) {
    if (bmi < 18.5) {
      return "Below weight";
    } else if (bmi >= 18.5 && bmi < 25) {
      return "Ideal Weight";
    } else if (bmi >= 25 && bmi < 30) {
      return "Slightly Overweight";
    } else if (bmi >= 30 && bmi < 35){
      return "Obesity Grade I";
    } else if (bmi >= 35 && bmi < 39){
      return "Obesity Grade II";
    } else {
      return "Obesity Grade III";
    }
  }
  Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue; // Below weight
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return Colors.green; // Ideal Weight
    } else if (bmi >= 25 && bmi < 29.9) {
      return Colors.yellow; // Slightly Overweight
    } else if (bmi >= 30 && bmi < 34.9) {
      return Colors.orange; // Obesity Grade I
    } else if (bmi >= 35 && bmi < 39.9) {
      return Colors.purple; // Obesity Grade II
    } else {
      return Colors.red; // Obesity Grade III
    }
  }
}