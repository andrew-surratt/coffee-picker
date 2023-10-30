import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/components/comparison_chart.dart';
import 'package:coffee_picker/services/auth.dart';
import 'package:coffee_picker/utils/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/coffees.dart';
import '../repositories/ratings.dart';

class RatingInput extends ConsumerWidget {
  RatingInput({super.key});

  final _formKey = GlobalKey<FormState>();

  List<
      ({
        String coffeeName,
        TextEditingController controller,
        String coffeeRef
      })> nameToControllers = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<List<Coffee>> coffees = getCoffees();

    return FutureBuilder(
        future: coffees,
        builder: (BuildContext context, AsyncSnapshot<List<Coffee>> snapshot) {
          List<Coffee> coffees = snapshot.data ?? [];

          List<Widget> formFields = buildFormFields(context, ref, coffees);

          var inputForm = Padding(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: formFields,
                ),
              ));
          return ScaffoldBuilder(body: inputForm);
        });
  }

  List<Widget> buildFormFields(BuildContext context, WidgetRef ref, List<Coffee> coffees) {
    nameToControllers = coffees
        .map((e) => (
              coffeeName: e.name,
              controller: TextEditingController(),
              coffeeRef: e.ref
            ))
        .toList();
    return [
      ...nameToControllers.map((e) => buildFormFieldDouble(
          controller: e.controller,
          label: "Rating of ${e.coffeeName} 1-10",
          hint: '5',
          validationText: () => 'Please enter a rating 1-10',
          isInvalid: (value) => value < 1 || value > 10)),
      buildSubmitButton(ref, coffees, context)
    ];
  }

  Padding buildSubmitButton(
      WidgetRef ref, List<Coffee> coffeeData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          // var userId = getUser()?.uid ?? '';
          // for (var element in nameToControllers) {
          //   addRating(Rating(
          //       rating: double.parse(element.controller.text),
          //           review: ''
          //   ),
          //     element.coffeeRef,
          //
          //   );
          // }

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ComparisonChart(
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
