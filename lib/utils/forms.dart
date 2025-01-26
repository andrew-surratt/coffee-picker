import 'package:flutter/material.dart';

TextFormField buildFormFieldDouble({
  required TextEditingController controller,
  required String label,
  required String hint,
  String Function()? validationText,
  bool Function(double value)? isInvalid,
}) {
  return buildTextFormField(
      controller: controller,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      label: label,
      hint: hint,
      validationText: validationText,
      isInvalid: (value) {
        return double.tryParse(value) == null ||
            (isInvalid != null && isInvalid(double.parse(value)));
      });
}

Widget buildFormFieldTextAutocomplete({
  required TextEditingController controller,
  required FocusNode focusNode,
  required String label,
  required String hint,
  String Function()? validationText,
  String? emptyValidationText,
  TextInputType? textInputType,
  TextStyle? style,
  bool obscureText = false,
  bool readOnly = false,
  bool Function(String value)? isInvalid,
  List<String> autocompleteOptions = const [],
}) {
  return RawAutocomplete<String>(
    optionsViewBuilder: (context, onSelected, options) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 1.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            elevation: 2.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final dynamic option = options.elementAt(index);
                  return TextButton(
                    onPressed: () {
                      onSelected(option);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Text(
                          '$option',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
    optionsBuilder: (TextEditingValue textEditingValue) {
      if (textEditingValue.text == '') {
        return const Iterable<String>.empty();
      }
      return autocompleteOptions.where((String option) {
        return option
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase());
      });
    },
    onSelected: (String selectedTag) {
      controller.text = selectedTag;
    },
    textEditingController: controller,
    focusNode: focusNode,
    fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
      return buildTextFormField(
        controller: ttec,
        focusNode: tfn,
        hint: hint,
        label: label,
        validationText: validationText,
        emptyValidationText: emptyValidationText,
        textInputType: textInputType,
        obscureText: obscureText,
        isInvalid: isInvalid,
        readOnly: readOnly,
        style: style,
      );
    },
  );
}

TextFormField buildFormFieldText({
  required TextEditingController controller,
  required String label,
  required String hint,
  String Function()? validationText,
  String? emptyValidationText,
  TextInputType? textInputType,
  TextStyle? style,
  bool obscureText = false,
  bool readOnly = false,
  bool Function(String value)? isInvalid,
}) {
  return buildTextFormField(
    controller: controller,
    hint: hint,
    label: label,
    validationText: validationText,
    emptyValidationText: emptyValidationText,
    textInputType: textInputType,
    obscureText: obscureText,
    isInvalid: isInvalid,
    readOnly: readOnly,
    style: style,
  );
}

TextFormField buildTextFormField({
  required TextEditingController controller,
  required String label,
  required String hint,
  FocusNode? focusNode,
  String Function()? validationText,
  String? emptyValidationText,
  TextInputType? textInputType,
  TextStyle? style,
  bool obscureText = false,
  bool readOnly = false,
  bool Function(String value)? isInvalid,
}) {
  return TextFormField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: textInputType,
    obscureText: obscureText,
    readOnly: readOnly,
    style: style,
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
      labelText: label,
      hintText: hint,
    ),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (String? value) {
      if (validationText == null) {
        return null;
      } else if (value == null || value.isEmpty) {
        return emptyValidationText ?? validationText();
      } else if (isInvalid != null && isInvalid(value)) {
        return validationText();
      }
      return null;
    },
  );
}

Widget buildCheckboxField({
  required bool isChecked,
  required void Function(bool?) onChanged,
  required String label,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [Checkbox(value: isChecked, onChanged: onChanged), Text(label)],
  );
}
