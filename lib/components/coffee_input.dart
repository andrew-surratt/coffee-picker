import 'package:coffee_picker/components/scaffold.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/coffees.dart';
import '../services/coffee.dart';
import '../services/finance.dart';
import '../utils/forms.dart';

class CoffeeInput extends ConsumerWidget {
  CoffeeInput({super.key});

  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final cost = TextEditingController();
  final weight = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var inputForm = Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildFormFieldText(
                controller: name,
                hint: 'Coffee Name',
                validationText: () => 'Please enter a coffee'
              ),
              buildFormFieldDouble(
                controller: cost,
                hint: 'Cost of beans/grounds',
                validationText: () => 'Please enter an amount',
              ),
              buildFormFieldDouble(
                controller: weight,
                hint: 'Weight of beans/grounds (oz)',
                validationText: () => 'Please enter an amount',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    var costValue = double.parse(cost.value.text);
                    var weightValue = double.parse(weight.value.text);
                    var costPerOz =
                        toPrecision(calculateCostPerOz(costValue, weightValue));
                    addCoffee(CoffeeCreateReq(
                        name: name.value.text,
                        costPerOz: costPerOz,
                        ));

                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
              )
            ],
          ),
        ));
    return ScaffoldBuilder(body: inputForm);
  }

}
