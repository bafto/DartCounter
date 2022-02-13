import 'package:flutter/services.dart';

class MyNumberInput extends TextInputFormatter {
  final double min;
  final double max;

  MyNumberInput({this.min = -9007199254740991, this.max = 9007199254740991});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return const TextEditingValue().copyWith(text: min.toInt().toString());
    } else {
      return int.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}