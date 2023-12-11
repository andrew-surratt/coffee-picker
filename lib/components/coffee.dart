import 'package:coffee_picker/components/origin.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/components/thumbnail.dart';
import 'package:coffee_picker/providers/icons.dart';
import 'package:coffee_picker/services/auth.dart';
import 'package:coffee_picker/utils/forms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/coffees.dart';
import '../repositories/ratings.dart';

class CoffeeInfo extends ConsumerStatefulWidget {
  final Coffee coffee;

  const CoffeeInfo({super.key, required this.coffee});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CoffeeInfo();
}

class _CoffeeInfo extends ConsumerState<CoffeeInfo> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController ratingController = TextEditingController();
  TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? user = getUser();
    Future<List<Rating>> ratings = getCoffeeRatings(widget.coffee);
    return FutureBuilder(
        future: ratings,
        builder: (BuildContext context, AsyncSnapshot<List<Rating>> snapshot) {
          List<Rating> reviews = snapshot.data ?? [];

          List<Widget> formFields =
              buildFormFields(context, ref, widget.coffee, user);

          var inputForm = Padding(
              padding: const EdgeInsets.all(0),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                            child: Thumbnail(thumbnailPath: widget.coffee.thumbnailPath),
                        ),
                        Flexible(
                          flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: buildInfo(),
                              ),
                            ),
                        ),
                      ],
                    ),
                const Divider(height: 50, thickness: 1),
                buildForm(formFields),
                ...buildReview(reviews),
              ]));
          return ScaffoldBuilder(body: inputForm);
        });
  }

  List<Widget> buildInfo() {
    var icons = ref.watch(iconsProvider);

    List<Widget> tastingNotesRow = [];
    for (var note in widget.coffee.tastingNotes) {
      if (tastingNotesRow.isNotEmpty) {
        tastingNotesRow.add(const Text(' | '));
      }
      tastingNotesRow.add(Text(
        note,
        style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      ));
    }

    var h1Style = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

    var fairTradeIcon = icons.value?.fairTrade;
    var organicIcon = icons.value?.organic;
    List<Widget> iconsRow = [];
    const iconPadding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    if (fairTradeIcon != null && widget.coffee.fairTrade) {
      iconsRow.add(Padding(padding: iconPadding, child: Image.memory(
        fairTradeIcon,
        scale: 8,
        semanticLabel: 'Fair Trade Certified',
      )));
    }
    if (organicIcon != null && widget.coffee.usdaOrganic) {
      iconsRow.add(Padding(padding: iconPadding, child: Image.memory(
        organicIcon,
        scale: 8,
        semanticLabel: 'USDA Organic Certified',
      )));
    }

    return [
      Text(widget.coffee.name, style: h1Style),
      Text("(\$${widget.coffee.costPerOz.toString()} / oz)"),
      Wrap(
          children: tastingNotesRow
      ),
      OriginText(origins: widget.coffee.origins),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: iconsRow,
      ),
    ];
  }

  Form buildForm(List<Widget> formFields) {
    return Form(
      key: _formKey,
      child: Card(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: formFields,
      )),
    );
  }

  List<Widget> buildFormFields(
      BuildContext context, WidgetRef ref, Coffee coffees, User? user) {
    if (user == null) {
      return [];
    }
    const edgeInsets = EdgeInsets.symmetric(vertical: 10, horizontal: 15);
    return [
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 1,
                child: Padding(
                  padding: edgeInsets,
                  child: buildFormFieldDouble(
                      controller: ratingController,
                      label: "Rating",
                      hint: '5',
                      validationText: () => 'Enter a rating 1-10',
                      isInvalid: (value) => value < 1 || value > 10),
                )),
            Flexible(
              flex: 3,
              child: Padding(
                  padding: edgeInsets,
                  child: buildFormFieldText(
                    controller: reviewController,
                    label: "Review",
                    hint: 'Good',
                  )),
            ),
            Padding(
              padding: edgeInsets,
              child: buildSubmitButton(context, ref, widget.coffee, user),
            ),
          ]),
    ];
  }

  Padding buildSubmitButton(
    BuildContext context,
    WidgetRef ref,
    Coffee coffeeData,
    User user,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FilledButton(
        onPressed: () {
          setState(() {
            addRating(
              Rating(
                userRef: user.uid,
                userName: user.displayName ?? 'Anonymous',
                coffeeRef: coffeeData.ref,
                coffeeName: coffeeData.name,
                rating: double.parse(ratingController.text),
                review: reviewController.text ?? '',
              ),
            );
            ratingController.clear();
            reviewController.clear();
            _formKey.currentState?.reset();
          });
        },
        child: const Text('Submit'),
      ),
    );
  }

  List<Card> buildReview(List<Rating> reviews) {
    return reviews
        .map((r) {
          var reviewBody = Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.userName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${r.rating}/10",
                      style: const TextStyle(
                        height: 2,
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  r.review.isNotEmpty ? Text(r.review) : const Text('...'),
                ],
              );
          return Card(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                reviewBody
              ],)
            ));
        })
        .toList();
  }
}
