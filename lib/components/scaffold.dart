import 'package:coffee_picker/components/coffees.dart';
import 'package:coffee_picker/components/comparison_chart.dart';
import 'package:coffee_picker/components/user_profile.dart';
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
        backgroundColor: themeData.colorScheme.primary,
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
    var theme = Theme.of(context);
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: const Row(
                  children: [
                    Icon(Icons.coffee),
                    Spacer(),
                  ]
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Coffees()));
            },
          ),
          ListTile(
            title: const Text('Demo'),
            leading: const Icon(Icons.construction),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => CoffeeInput()));
            },
          ),
          ListTile(
            title: const Text('Compare'),
            leading: const Icon(Icons.bar_chart),
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
          const Spacer(),
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.person),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfile(),
                  ));
            },
          )
        ],
      ),
    );
  }
}
