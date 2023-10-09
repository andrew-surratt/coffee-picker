import 'package:flutter/material.dart';

TextFormField buildFormFieldDouble({
  required TextEditingController controller,
  required String hint,
  required String validationText,
  bool Function(double value)? isInvalid,
}) {
  return buildTextFormField(
      controller: controller,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      hint: hint,
      validationText: validationText,
      isInvalid: (value) {
        return double.tryParse(value) == null || (isInvalid != null && isInvalid(double.parse(value)));
      }
  );
}

TextFormField buildFormFieldText({
  required TextEditingController controller,
  required String hint,
  required String validationText,
}) {
  return buildTextFormField(
      controller: controller,
      hint: hint,
      validationText: validationText,
  );
}

TextFormField buildTextFormField({
  required TextEditingController controller,
  required String hint,
  required String validationText,
  TextInputType? textInputType,
  bool Function(String value)? isInvalid,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: textInputType,
    decoration: InputDecoration(
      hintText: hint,
    ),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (String? value) {
      if (value == null || value.isEmpty ||
          (isInvalid != null && isInvalid(value))) {
        return validationText;
      }
      return null;
    },
  );
}
