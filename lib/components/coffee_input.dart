import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/repositories/taste_notes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../repositories/coffees.dart';
import '../services/coffee.dart';
import '../services/finance.dart';
import '../utils/forms.dart';
import 'coffees.dart';

class CoffeeInput extends ConsumerStatefulWidget {
  var originFields = [
    (
      origin: TextEditingController(),
      originPercentage: TextEditingController(),
    )
  ];

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CoffeeInput();
}

class _CoffeeInput extends ConsumerState<CoffeeInput> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final tasteNotes = TextfieldTagsController();
  final cost = TextEditingController();
  final weight = TextEditingController();
  final startingFormFieldsCount = 4;
  final endingFormFieldsCount = 2;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var formFieldsCount = startingFormFieldsCount +
        widget.originFields.length +
        endingFormFieldsCount;

    var inputForm = Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: formFieldsCount,
          itemBuilder: (context, index) {
            if (index == formFieldsCount - 1) {
              return buildSubmitButton(context);
            } else if (index == formFieldsCount - 2) {
              return buildAddOriginButton(context);
            } else if (index == 0) {
              return buildFormFieldText(
                  controller: name,
                  hint: 'Coffee Name',
                  validationText: () => 'Enter a coffee');
            } else if (index == 1) {
              return buildMultiTagField(
                  controller: tasteNotes,
                  hintText: 'Tasting notes',
                  tagColor: theme.primaryColor);
            } else if (index == 2) {
              return buildFormFieldDouble(
                  controller: cost,
                  hint: 'Cost of beans/grounds',
                  validationText: () => 'Enter an amount');
            } else if (index == 3) {
              return buildFormFieldDouble(
                  controller: weight,
                  hint: 'Weight of beans/grounds (oz)',
                  validationText: () => 'Enter an amount');
            } else {
              return buildOriginField(index);
            }
          },
        ));
    return ScaffoldBuilder(
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: inputForm));
  }

  Row buildOriginField(int index) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
        flex: 5,
        child: buildFormFieldText(
            controller:
                widget.originFields[index - startingFormFieldsCount].origin,
            hint: 'Origin',
            validationText: () => 'Enter an origin country'),
      ),
      const Spacer(flex: 1),
      Flexible(
        flex: 2,
        child: buildFormFieldDouble(
            controller: widget
                .originFields[index - startingFormFieldsCount].originPercentage,
            hint: 'Percentage',
            validationText: () => 'Enter a percentage 1-100'),
      ),
      TextButton(
          onPressed: () {
            setState(() {
              widget.originFields.removeAt(index - startingFormFieldsCount);
            });
          },
          child: const Icon(Icons.close))
    ]);
  }

  Widget buildAddOriginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            widget.originFields.add((
              origin: TextEditingController(),
              originPercentage: TextEditingController(),
            ));
          });
        },
        child: const Text('Add another origin'),
      ),
    );
  }

  Padding buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          var costValue = double.parse(cost.value.text);
          var weightValue = double.parse(weight.value.text);
          var costPerOz =
              toPrecision(calculateCostPerOz(costValue, weightValue));
          var origins = widget.originFields
              .map((e) => CoffeeOrigin(
                    origin: e.origin.text,
                    percentage: double.parse(e.originPercentage.text),
                  ))
              .toList();

          addCoffee(CoffeeCreateReq(
            name: name.value.text,
            costPerOz: costPerOz,
            tastingNotes: tasteNotes.getTags ?? [],
            origins: origins,
          ));

          tasteNotes.getTags?.forEach((element) {
            addTastingNote(element);
          });

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Coffees(),
              ));
        },
        child: const Text('Submit'),
      ),
    );
  }
}
