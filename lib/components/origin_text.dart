import 'package:flutter/material.dart';

import '../repositories/coffees.dart';

class OriginText extends StatelessWidget {
  final List<CoffeeOrigin> origins;
  final String? separator;
  final TextStyle? originTextStyle;
  final int? maxLines;

  const OriginText({
    super.key,
    required this.origins,
    this.separator,
    this.originTextStyle,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    String originsRow = '';
    for (var origin in origins) {
      if (originsRow.isNotEmpty) {
        originsRow += " ${separator ?? '|'} ";
      }
      originsRow += "${origin.percentage.floor()}% ${origin.origin}";
    }

    return Text(
      originsRow,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      style: originTextStyle ?? const TextStyle(fontStyle: FontStyle.italic),
    );
  }
}