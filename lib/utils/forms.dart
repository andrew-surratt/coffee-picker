import 'package:flutter/material.dart';

TextFormField buildFormFieldDouble({
  required TextEditingController controller,
  required String hint,
  required String Function() validationText,
  bool Function(double value)? isInvalid,
}) {
  return buildTextFormField(
      controller: controller,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      hint: hint,
      validationText: validationText,
      isInvalid: (value) {
        return double.tryParse(value) == null ||
            (isInvalid != null && isInvalid(double.parse(value)));
      });
}

TextFormField buildFormFieldText({
  required TextEditingController controller,
  required String hint,
  required String Function() validationText,
  String? emptyValidationText,
  TextInputType? textInputType,
  bool obscureText = false,
  bool Function(String value)? isInvalid,
}) {
  return buildTextFormField(
    controller: controller,
    hint: hint,
    validationText: validationText,
    emptyValidationText: emptyValidationText,
    textInputType: textInputType,
    obscureText: obscureText,
    isInvalid: isInvalid,
  );
}

TextFormField buildTextFormField({
  required TextEditingController controller,
  required String hint,
  required String Function() validationText,
  String? emptyValidationText,
  TextInputType? textInputType,
  bool obscureText = false,
  bool Function(String value)? isInvalid,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: textInputType,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hint,
    ),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (String? value) {
      if (value == null ||
          value.isEmpty
      ) {
        return emptyValidationText ?? validationText();
      } else if (isInvalid != null && isInvalid(value)) {
        return validationText();
      }
      return null;
    },
  );
}
