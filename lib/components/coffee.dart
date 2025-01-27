import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_picker/components/origin_text.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/components/thumbnail.dart';
import 'package:coffee_picker/providers/compare_coffees.dart';
import 'package:coffee_picker/providers/icons.dart';
import 'package:coffee_picker/services/auth.dart';
import 'package:coffee_picker/utils/forms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/config.dart';
import '../repositories/coffees.dart';
import '../repositories/configs.dart';
import '../repositories/ratings.dart';

class CoffeeInfo extends ConsumerStatefulWidget {
  final Coffee coffee;

  const CoffeeInfo({super.key, required this.coffee});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CoffeeInfo();
}

enum MenuItem { addToComparison }

class _CoffeeInfo extends ConsumerState<CoffeeInfo> {
  final _formKey = GlobalKey<FormState>();
  final double defaultRating = 3.0;

  late double ratingController;
  TextEditingController reviewController = TextEditingController();
  final TextEditingController _aromaSliderValue =
      TextEditingController(text: 5.toString());
  final TextEditingController _aciditySliderValue =
      TextEditingController(text: 5.toString());
  final TextEditingController _sweetnessSliderValue =
      TextEditingController(text: 5.toString());
  final TextEditingController _bodySliderValue =
      TextEditingController(text: 5.toString());
  final TextEditingController _finishSliderValue =
      TextEditingController(text: 5.toString());

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ratingController = defaultRating;
    User? user = getUser();
    Future<List<Rating>> ratings = getCoffeeRatings(widget.coffee);
    final AsyncValue<Config> config = ref.watch(configProvider);

    return FutureBuilder(
        future: ratings,
        builder: (BuildContext context, AsyncSnapshot<List<Rating>> snapshot) {
          List<Rating> reviews = snapshot.data ?? [];

          var inputForm = ListView(children: [
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
            ExpansionTile(
              title: Text('Leave a review'),
              collapsedBackgroundColor: theme.focusColor,
              backgroundColor: theme.focusColor,
              collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              children: <Widget>[
                buildForm(buildFormFields(context, ref, widget.coffee, user)),
              ],
            ),
            const Divider(height: 50, thickness: 1),
            ...buildReview(reviews),
          ]);
          return ScaffoldBuilder(
            body: inputForm,
            appBarActions: (config.value?.isComparisonChartEnabled ?? false)
                ? [
                    PopupMenuButton<MenuItem>(
                      onSelected: (MenuItem i) {
                        switch (i) {
                          case MenuItem.addToComparison:
                            ref
                                .read(compareCoffeesProvider)
                                .addCoffee(widget.coffee, getUser());
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<MenuItem>(
                            value: MenuItem.addToComparison,
                            child: Text('Add to comparison'),
                          ),
                        ];
                      },
                    ),
                  ]
                : null,
          );
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
        style: const TextStyle(
            fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      ));
    }

    var h1Style = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

    var fairTradeIcon = icons.value?.fairTrade;
    var organicIcon = icons.value?.organic;
    List<Widget> iconsRow = [];
    const iconPadding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    if (fairTradeIcon != null && widget.coffee.fairTrade) {
      iconsRow.add(Padding(
          padding: iconPadding,
          child: Image.memory(
            fairTradeIcon,
            scale: 8,
            semanticLabel: 'Fair Trade Certified',
          )));
    }
    if (organicIcon != null && widget.coffee.usdaOrganic) {
      iconsRow.add(Padding(
          padding: iconPadding,
          child: Image.memory(
            organicIcon,
            scale: 8,
            semanticLabel: 'USDA Organic Certified',
          )));
    }

    return [
      Text(widget.coffee.roaster),
      Text(widget.coffee.name, style: h1Style),
      Text("(\$${widget.coffee.costPerOz.toString()} / oz)"),
      Wrap(children: tastingNotesRow),
      OriginText(
        origins: widget.coffee.origins,
        maxLines: 3,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: iconsRow,
      ),
    ];
  }

  Form buildForm(Widget? formFields) {
    return Form(
      key: _formKey,
      child: Card(
        child: formFields,
      ),
    );
  }

  Widget? buildFormFields(
      BuildContext context, WidgetRef ref, Coffee coffees, User? user) {
    if (user == null) {
      return null;
    }

    const edgeInsets = EdgeInsets.symmetric(vertical: 5, horizontal: 15);
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: edgeInsets,
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
                ratingController = rating;
              },
            ),
          ),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(_aromaSliderValue, 'Aroma')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(_aciditySliderValue, 'Acidity')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(_sweetnessSliderValue, 'Sweetness')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(_bodySliderValue, 'Body')),
          Padding(
              padding: edgeInsets,
              child: buildSliderReview(_finishSliderValue, 'Finish')),
          Padding(
              padding: edgeInsets,
              child: buildFormFieldText(
                controller: reviewController,
                label: "Review",
                hint: 'Good',
              )),
          Padding(
            padding: edgeInsets,
            child: buildSubmitButton(context, ref, widget.coffee, user),
          ),
        ]);
  }

  Widget buildSubmitButton(
    BuildContext context,
    WidgetRef ref,
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
            rating: ratingController,
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
          });
        });
      },
      child: const Text('Submit'),
    );
  }

  List<Card> buildReview(List<Rating> reviews) {
    if (kDebugMode) {
      print("Building reviews for ${widget.coffee.name}: ${reviews.map((r) {
        return r.userName;
      }).join(", ")}");
    }
    return reviews.map((r) {
      var reviewBody = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(r.userName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          RatingBarIndicator(
            rating: r.rating,
            direction: Axis.horizontal,
            itemSize: 20,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(horizontal: 1),
                label: Text("Aroma ${r.aromaValue.round()}"),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(horizontal: 1),
                label: Text("Acidity ${r.acidityValue.round()}"),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(horizontal: 1),
                label: Text("Sweetness ${r.sweetnessValue.round()}"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(horizontal: 1),
                label: Text("Body ${r.bodyValue.round()}"),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(horizontal: 1),
                label: Text("Finish ${r.finishValue.round()}"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: r.review.isNotEmpty ? Text(r.review) : const Text('...'),
          ),
        ],
      );
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [reviewBody],
              )));
    }).toList();
  }

  Widget buildSliderReview(TextEditingController field, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(title)),
        Flexible(
            child: Slider(
          value: double.tryParse(field.value.text) ?? 5,
          min: 1,
          max: 10,
          divisions: 10,
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
