import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

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

TextFormField buildFormFieldText({
  required TextEditingController controller,
  required String label,
  required String hint,
  String Function()? validationText,
  String? emptyValidationText,
  TextInputType? textInputType,
  bool obscureText = false,
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
  );
}

TextFormField buildTextFormField({
  required TextEditingController controller,
  required String label,
  required String hint,
  String Function()? validationText,
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

Padding buildMultiTagField({
  required TextfieldTagsController controller,
  required String label,
  required String hintText,
  required ThemeData theme,
  Color? tagColor,
}) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: TextFieldTags(
        textfieldTagsController: controller,
        letterCase: LetterCase.small,
        inputfieldBuilder: (BuildContext context,
            TextEditingController tec,
            FocusNode fn,
            String? error,
            void Function(String value)? onChanged,
            void Function(String value)? onSubmitted) {
          return createTagsBuilder(tec: tec,
              fn: fn,
              controller: controller,
              hintText: hintText,
              label: label,
              theme: theme,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              error: error,
              tagColor: tagColor);
        },
      ));
}

TagsBuilder createTagsBuilder({
  required TextEditingController tec,
  required FocusNode fn,
  required TextfieldTagsController controller,
  required String hintText,
  required String label,
  required ThemeData theme,
  void Function(String value)? onChanged,
  void Function(String value)? onSubmitted,
  String? error,
  Color? tagColor,
}) {
  return (BuildContext context, ScrollController sc, List<String> tags,
      void Function(String tag) onDeleteTag) {
    return TextFormField(
      controller: tec,
      focusNode: fn,
      onChanged: onChanged,
      onFieldSubmitted: (String value) {
        if (onSubmitted != null) {
          fn.requestFocus();
          return onSubmitted(value);
        }
      },
      style: theme.textTheme.labelMedium,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: controller.hasTags ? '' : hintText,
        floatingLabelBehavior: controller.hasTags
            ? FloatingLabelBehavior.always
            : FloatingLabelBehavior.auto,
        errorText: error,
        prefixIcon: tags.isNotEmpty
            ? SingleChildScrollView(
          controller: sc,
          scrollDirection: Axis.horizontal,
          child: Row(
              children: tags.map((String tag) {
                return buildTagField(tagColor: tagColor, tag: tag, onDeleteTag: onDeleteTag, theme: theme);
              }).toList()),
        )
            : null,
      ),
    );
  };
}

Container buildTagField({
    required String tag,
    required void Function(String tag) onDeleteTag,
    required ThemeData theme,
    Color? tagColor,
}) {
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
          child: Text(tag, style: theme.textTheme.labelMedium?.copyWith(color: theme.cardColor)),
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
