import 'package:flutter/material.dart';

class ScaffoldBuilder extends StatelessWidget {
  final Widget body;

  final String widgetTitle;

  final void Function()? onNextPressed;

  const ScaffoldBuilder(
      {super.key, required this.body, required this.widgetTitle, this.onNextPressed});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.inversePrimary,
        title: Text(widgetTitle),
      ),
      body: Center(child: body),
      floatingActionButton: onNextPressed != null ? FloatingActionButton.small(
        onPressed: onNextPressed,
        child: const Icon(Icons.navigate_next)
      ) : null,
    );
  }
}
