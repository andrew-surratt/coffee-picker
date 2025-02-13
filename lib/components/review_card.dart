import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../repositories/ratings.dart';

class ReviewCard extends StatelessWidget {
  final Rating rating;
  final bool showCoffeeName;
  final bool showUserName;
  final void Function()? onTap;

  const ReviewCard({
    super.key,
    required this.rating,
    this.showCoffeeName = false,
    this.showUserName = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var createdDate = rating.createdAt?.toDate();
    var formattedCreatedDate =
        createdDate != null ? DateFormat.yMMMMd().format(createdDate) : '';

    var reviewBody = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCoffeeName == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(rating.coffeeName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        if (showUserName == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(rating.userName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(formattedCreatedDate,
              style:
                  const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ),
        RatingBarIndicator(
          rating: rating.rating,
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
              label: Text("Aroma ${rating.aromaValue.round()}"),
            ),
            Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: 1),
              label: Text("Acidity ${rating.acidityValue.round()}"),
            ),
            Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: 1),
              label: Text("Sweetness ${rating.sweetnessValue.round()}"),
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
              label: Text("Body ${rating.bodyValue.round()}"),
            ),
            Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: 1),
              label: Text("Finish ${rating.finishValue.round()}"),
            ),
          ],
        ),
        Flexible(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: rating.review.isNotEmpty
              ? Text(
                  rating.review,
                )
              : const Text('...'),
        )),
      ],
    );

    var reviewCard = Padding(
      padding: const EdgeInsets.all(10),
      child: reviewBody,
    );

    if (onTap != null) {
      return Card(
          child: InkWell(
              onTap: onTap,
              splashColor: theme.primaryColor,
              child: reviewCard));
    }
    return Card(child: reviewCard);
  }
}
