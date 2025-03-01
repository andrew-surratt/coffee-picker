import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../repositories/coffees.dart';
import '../repositories/ratings.dart';
import '../services/auth.dart';
import '../utils/forms.dart';

class Review extends StatefulWidget {
  final Coffee coffee;
  final void Function(Rating? value) onSubmit;

  const Review({super.key, required this.coffee, required this.onSubmit});

  @override
  State<StatefulWidget> createState() {
    return _ReviewState();
  }
}

class _ReviewState extends State<Review> {
  final _formKey = GlobalKey<FormState>();
  final double defaultRating = 3.0;
  TextEditingController ratingController = TextEditingController(text: '3');
  TextEditingController reviewController = TextEditingController();
  final TextEditingController _aromaSliderValue =
      TextEditingController(text: "5");
  final TextEditingController _aciditySliderValue =
      TextEditingController(text: "5");
  final TextEditingController _sweetnessSliderValue =
      TextEditingController(text: "5");
  final TextEditingController _bodySliderValue =
      TextEditingController(text: "5");
  final TextEditingController _finishSliderValue =
      TextEditingController(text: "5");

  @override
  Widget build(BuildContext context) {
    User? user = getUser();

    return buildForm(buildFormFields(context, widget.coffee, user));
  }

  Form buildForm(Widget? formFields) {
    return Form(
      key: _formKey,
      child: Card(
        child: formFields,
      ),
    );
  }

  Widget? buildFormFields(BuildContext context, Coffee coffees, User? user) {
    if (user == null) {
      return null;
    }

    const edgeInsets = EdgeInsets.symmetric(vertical: 5, horizontal: 15);
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 500,
            child: Container(
              padding: edgeInsets,
              alignment: Alignment.center,
              child: RatingBar.builder(
                initialRating: defaultRating,
                minRating: 1,
                direction: Axis.horizontal,
                itemSize: 30,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    ratingController.text = rating.toString();
                  });
                },
              ),
            ),
          ),
          Padding(
              padding: edgeInsets,
              child:
                  buildSliderReview(_aromaSliderValue, 'Aroma', 'Low to High')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(
                  _aciditySliderValue, 'Acidity', 'Low to High')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(
                  _sweetnessSliderValue, 'Sweetness', 'Low to High')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(
                  _bodySliderValue, 'Body', 'Light to Heavy')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(
                  _finishSliderValue, 'Finish', 'Short to Long')),
          Padding(
              padding: edgeInsets,
              child: buildFormFieldText(
                controller: reviewController,
                label: "Review Notes",
                hint: 'Good',
              )),
          Padding(
            padding: edgeInsets,
            child: buildSubmitButton(context, widget.coffee, user),
          ),
        ]);
  }

  Widget buildSubmitButton(
    BuildContext context,
    Coffee coffeeData,
    User user,
  ) {
    return FilledButton(
      onPressed: () {
        addRating(
          Rating(
            userRef: user.uid,
            userName: user.displayName ?? 'Anonymous',
            coffeeRef: coffeeData.ref,
            coffeeName: coffeeData.name,
            rating: double.tryParse(ratingController.text) ?? defaultRating,
            aromaValue: double.tryParse(_aromaSliderValue.text) ?? 5,
            acidityValue: double.tryParse(_aciditySliderValue.text) ?? 5,
            sweetnessValue: double.tryParse(_sweetnessSliderValue.text) ?? 5,
            bodyValue: double.tryParse(_bodySliderValue.text) ?? 5,
            finishValue: double.tryParse(_finishSliderValue.text) ?? 5,
            review: reviewController.text,
            createdAt: Timestamp.now(),
          ),
        ).then((value) {
          setState(() {
            reviewController.clear();
            _formKey.currentState?.reset();
            widget.onSubmit(value.data());
          });
        });
      },
      child: const Text('Submit'),
    );
  }

  Widget buildSliderReview(
      TextEditingController field, String title, String tooltip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(title)),
        Tooltip(
            message: tooltip,
            child: Icon(
              Icons.info_outline,
            )),
        Flexible(
            child: Slider(
          value: double.tryParse(field.value.text) ?? 5,
          min: 1,
          max: 10,
          divisions: 9,
          label: field.value.text,
          onChanged: (double value) {
            setState(() {
              field.text = value.round().toString();
            });
          },
        ))
      ],
    );
  }
}
