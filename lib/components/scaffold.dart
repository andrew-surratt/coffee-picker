import 'package:flutter/material.dart';

class ScaffoldBuilder extends StatelessWidget {
  final Widget body;

  final String widgetTitle;

  const ScaffoldBuilder(
      {super.key, required this.body, required this.widgetTitle});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.inversePrimary,
        title: Text(widgetTitle),
      ),
      body: body,
    );
  }
}
