import 'package:coffee_picker/components/origin_text.dart';
import 'package:coffee_picker/components/review.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/components/thumbnail.dart';
import 'package:coffee_picker/providers/compare_coffees.dart';
import 'package:coffee_picker/providers/icons.dart';
import 'package:coffee_picker/services/auth.dart';
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
  ExpansionTileController expansionTileController = ExpansionTileController();
  late List<Rating> ratings = [];

  @override
  void initState() {
    super.initState();
    initRatings();
  }

  void initRatings() async {
    var r = await getCoffeeRatings(widget.coffee);
    setState(() {
      ratings = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final AsyncValue<Config> config = ref.watch(configProvider);

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
        controller: expansionTileController,
        collapsedBackgroundColor: theme.focusColor,
        backgroundColor: theme.focusColor,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        children: <Widget>[
          Review(
              coffee: widget.coffee,
              onSubmit: (rating) {
                expansionTileController.collapse();
                initRatings();
              }),
        ],
      ),
      const Divider(height: 50, thickness: 1),
      ...buildReview(ratings),
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
}
