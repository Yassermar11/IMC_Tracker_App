import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BMICalculator {
  static double calculateBMI(double weight, double height) {
    return weight / (height * height);
  }

  static String getBMIResult(BuildContext context, double bmi, [String? resultKey]) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'Localization Error';

    final key = resultKey ?? getBMIResultKey(bmi);

    switch (key) {
      case 'Below weight': return l10n.bmiUnderweight;
      case 'Ideal Weight': return l10n.bmiNormal;
      case 'Slightly Overweight': return l10n.bmiOverweight;
      case 'Obesity Grade I': return l10n.bmiObesity1;
      case 'Obesity Grade II': return l10n.bmiObesity2;
      case 'Obesity Grade III': return l10n.bmiObesity3;
      default: return l10n.bmiUnknownCategory;
    }
  }
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24.9) return Colors.green;
    if (bmi < 29.9) return Colors.yellow;
    if (bmi < 34.9) return Colors.orange;
    if (bmi < 39.9) return Colors.purple;
    return Colors.red;
  }

  static String getBMIResultKey(double bmi) {
    if (bmi < 18.5) return 'Below weight';
    if (bmi < 24.9) return 'Ideal Weight';
    if (bmi < 29.9) return 'Slightly Overweight';
    if (bmi < 34.9) return 'Obesity Grade I';
    if (bmi < 39.9) return 'Obesity Grade II';
    return 'Obesity Grade III';
  }
}