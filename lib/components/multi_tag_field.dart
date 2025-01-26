import 'dart:math';

import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

class DynamicAutoCompleteTags extends StatefulWidget {
  final DynamicTagController<DynamicTagData> dynamicTagController;
  final List<DynamicTagData> initialTags;

  const DynamicAutoCompleteTags({super.key, required this.dynamicTagController, required this.initialTags});

  @override
  State<DynamicAutoCompleteTags> createState() =>
      _DynamicAutoCompleteTagsState();
}

class _DynamicAutoCompleteTagsState extends State<DynamicAutoCompleteTags> {
  late double _distanceToField;
  final random = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Autocomplete<DynamicTagData>(
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final DynamicTagData option =
                          options.elementAt(index);
                          return TextButton(
                            onPressed: () {
                              onSelected(option);
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option.tag,
                                textAlign: TextAlign.left,
                                style: theme.textTheme.labelMedium,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextFieldTags<DynamicTagData>(
                  textfieldTagsController: widget.dynamicTagController,
                  textEditingController: textEditingController,
                  focusNode: focusNode,
                  textSeparators: const [','],
                  letterCase: LetterCase.small,
                  validator: (DynamicTagData tag) {
                    if (widget.dynamicTagController.getTags!
                        .any((element) => element.tag == tag.tag)) {
                      return 'Already added';
                    }
                    return null;
                  },
                  inputFieldBuilder: (context, inputFieldValues) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: TextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Tasting Notes',
                          border: const OutlineInputBorder(),
                          hintText: inputFieldValues.tags.isNotEmpty
                              ? ''
                              : "chocolate",
                          errorText: inputFieldValues.error,
                          prefixIconConstraints:
                          BoxConstraints(maxWidth: _distanceToField * 0.74),
                          prefixIcon: inputFieldValues.tags.isNotEmpty
                              ? SingleChildScrollView(
                            controller:
                            inputFieldValues.tagScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: inputFieldValues.tags.map(
                                        (DynamicTagData tag) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              child: Text(
                                                tag.tag,
                                                style: theme.textTheme.labelSmall?.copyWith(color: theme.cardColor),
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            InkWell(
                                              child: const Icon(
                                                Icons.cancel,
                                                size: 14.0,
                                              ),
                                              onTap: () {
                                                inputFieldValues
                                                    .onTagRemoved(tag);
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList()),
                          )
                              : null,
                        ),
                        onChanged: (value) {
                          final tagData = DynamicTagData(value, null);
                          inputFieldValues.onTagChanged(tagData);
                        },
                        onSubmitted: (value) {
                          final tagData = DynamicTagData(value, null);
                          inputFieldValues.onTagSubmitted(tagData);
                        },
                      ),
                    );
                  },
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<DynamicTagData>.empty();
                }
                return widget.initialTags.where((DynamicTagData option) {
                  return option.tag
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (option) {
                widget.dynamicTagController.onTagSubmitted(option);
              },
            ),
          ],
        ),
      );
  }
}