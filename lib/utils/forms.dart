import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

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
      if (value == null || value.isEmpty) {
        return emptyValidationText ?? validationText();
      } else if (isInvalid != null && isInvalid(value)) {
        return validationText();
      }
      return null;
    },
  );
}

Padding buildMultiTagField({
  required TextfieldTagsController controller,
  required String hintText,
  Color? tagColor,
}) {
  return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: TextFieldTags(
        textfieldTagsController: controller,
        inputfieldBuilder: (BuildContext context,
            TextEditingController tec,
            FocusNode fn,
            String? error,
            void Function(String value)? onChanged,
            void Function(String value)? onSubmitted) {
          return createTagsBuilder(tec, fn, controller, hintText, onChanged,
              onSubmitted, error, tagColor);
        },
      ));
}

TagsBuilder createTagsBuilder(
    TextEditingController tec,
    FocusNode fn,
    TextfieldTagsController controller,
    String hintText,
    void Function(String value)? onChanged,
    void Function(String value)? onSubmitted,
    String? error,
    Color? tagColor) {
  return (BuildContext context, ScrollController sc, List<String> tags,
      void Function(String tag) onDeleteTag) {
    return TextFormField(
      controller: tec,
      focusNode: fn,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: controller.hasTags ? '' : hintText,
        errorText: error,
        prefixIcon: tags.isNotEmpty
            ? SingleChildScrollView(
                controller: sc,
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: tags.map((String tag) {
                  return buildTagField(tagColor, tag, onDeleteTag);
                }).toList()),
              )
            : null,
      ),
    );
  };
}

Container buildTagField(
    Color? tagColor, String tag, void Function(String tag) onDeleteTag) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(
        Radius.circular(20.0),
      ),
      color: tagColor,
    ),
    margin: const EdgeInsets.symmetric(horizontal: 5.0),
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          child: Text(tag),
        ),
        const SizedBox(width: 4.0),
        InkWell(
          child: const Icon(
            Icons.cancel,
            size: 14.0,
          ),
          onTap: () {
            onDeleteTag(tag);
          },
        )
      ],
    ),
  );
}
