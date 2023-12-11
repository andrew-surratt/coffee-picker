import 'package:flutter/material.dart';

import '../repositories/coffees.dart';

class OriginText extends StatelessWidget {
  final List<CoffeeOrigin> origins;
  final String? separator;
  final TextStyle? originTextStyle;
  final TextStyle? separatorTextStyle;

  const OriginText({
    super.key,
    required this.origins,
    this.separator,
    this.originTextStyle,
    this.separatorTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> originsRow = [];
    for (var origin in origins) {
      if (originsRow.isNotEmpty) {
        originsRow.add(Text(" ${separator ?? '|'} ", style: separatorTextStyle,));
      }
      originsRow.add(Text(
        "${origin.percentage.floor()}% ${origin.origin}",
        style: originTextStyle ?? const TextStyle(fontStyle: FontStyle.italic),
      ));
    }
    return Wrap(
      children: originsRow,
    );
  }
}