import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/components/comparison_chart.dart';
import 'package:coffee_picker/providers/coffees.dart';
import 'package:coffee_picker/utils/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatingInput extends ConsumerWidget {
  final String widgetTitle;

  RatingInput({super.key, required this.widgetTitle});

  final _formKey = GlobalKey<FormState>();

  List<({String coffeeName, TextEditingController controller})>
      nameToControllers = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coffeeData = ref.watch(coffeesProvider);
    nameToControllers = coffeeData
        .map((e) => (coffeeName: e.name, controller: TextEditingController()))
        .toList();
    List<Widget> formFields = [
      ...nameToControllers.map((e) => buildFormFieldDouble(
          controller: e.controller,
          hint: "Rating of ${e.coffeeName} 1-10",
          validationText: 'Please enter a rating 1-10',
        isInvalid: (value) => value < 1 || value > 10
      )),
      buildSubmitButton(ref, coffeeData, context)
    ];

    var inputForm = Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: formFields,
          ),
        ));
    return ScaffoldBuilder(body: inputForm, widgetTitle: widgetTitle);
  }

  Padding buildSubmitButton(
      WidgetRef ref, List<Coffee> coffeeData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          var coffeesNotifier = ref.read(coffeesProvider.notifier);
          coffeesNotifier.setCoffees(coffeeData.map((e) {
            var ratingInput = nameToControllers
                .firstWhere((c) => c.coffeeName == e.name)
                .controller
                .text;
            return Coffee(
                name: e.name,
                costPerOz: e.costPerOz,
                data: e.data,
                rating: double.parse(ratingInput));
          }).toList());

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ComparisonChart(
                      widgetTitle: widgetTitle,
                      chartComponents: [
                        ChartComponent(ComponentName.price),
                        ChartComponent(ComponentName.rating),
                      ],
                    )),
          );
        },
        child: const Text('Submit'),
      ),
    );
  }
}
