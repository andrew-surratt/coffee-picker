import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../repositories/coffee_images.dart';

class Thumbnail extends StatelessWidget {
  final double width;
  final double height;
  final String? thumbnailPath;

  const Thumbnail({
    super.key,
    required this.thumbnailPath,
    this.width = 110,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    Future<Uint8List?> thumbnail = downloadImage(thumbnailPath);
    return FutureBuilder(
        future: thumbnail,
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.data == null) {
            return buildSizedBox(context: context);
          }
          return buildSizedBox(
              context: context,
              widget: Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
                repeat: ImageRepeat.noRepeat,
                width: 256,
              ));
        });
  }

  Widget buildSizedBox({
    Widget? widget,
    required BuildContext context,
  }) {
    var theme = Theme.of(context);
    var childWidget = widget ??
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.disabledColor,
          ),
          child: const Icon(Icons.coffee),
        );
    return AspectRatio(
      aspectRatio: 1,
      child: childWidget,
    );
  }
}
