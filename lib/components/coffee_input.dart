import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/components/comparison_chart.dart';
import 'package:coffee_picker/providers/coffees.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/coffee.dart';
import '../services/finance.dart';

class CoffeeInput extends ConsumerWidget {
  final String widgetTitle;

  CoffeeInput({super.key, required this.widgetTitle});

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
              TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  hintText: 'Coffee Name',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cost,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Cost of beans/grounds',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: weight,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Weight of beans/grounds (oz)',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    var costValue = double.parse(cost.value.text);
                    var weightValue = double.parse(weight.value.text);
                    var costPerOz =
                        toPrecision(calculateCostPerOz(costValue, weightValue));
                    ref.read(coffeesProvider.notifier).addCoffee(Coffee(
                        name: name.value.text,
                        costPerOz: costPerOz,
                        data: LineChartBarData(
                          color: const Color(0xff202a44),
                          spots: generateCompoundInterestData(
                              calculateCostPerYearFromOz(costPerOz)),
                        )));

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ComparisonChart(
                                widgetTitle: widgetTitle,
                                chartComponents: [
                                  ChartComponent(ComponentName.price)
                                ],
                              )),
                    );
                  },
                  child: const Text('Submit'),
                ),
              )
            ],
          ),
        ));
    return ScaffoldBuilder(body: inputForm, widgetTitle: widgetTitle);
  }
}
