import 'package:coffee_picker/components/coffees.dart';
import 'package:coffee_picker/components/comparison_chart.dart';
import 'package:coffee_picker/components/rating_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/config.dart';
import '../repositories/configs.dart';
import 'coffee_input.dart';

class ScaffoldBuilder extends ConsumerWidget {
  final Widget body;

  final String? widgetTitle;

  final FloatingActionButton? floatingActionButton;

  const ScaffoldBuilder(
      {super.key,
      required this.body,
      this.widgetTitle,
      this.floatingActionButton});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var themeData = Theme.of(context);
    final AsyncValue<Config> config = ref.watch(configProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.inversePrimary,
        title: Text(config.value?.title ?? defaultConfig.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(child: body),
      ),
      floatingActionButton: floatingActionButton,
      drawer: buildDrawer(context),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Coffees()));
            },
          ),
          ListTile(
            title: const Text('Demo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => CoffeeInput()));
            },
          ),
          ListTile(
            title: const Text('Compare'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ComparisonChart(chartComponents: [
                            ChartComponent(ComponentName.price),
                            ChartComponent(ComponentName.rating),
                          ])));
            },
          ),
          ListTile(
            title: const Text('Rate'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => RatingInput()));
            },
          ),
        ],
      ),
    );
  }
}
