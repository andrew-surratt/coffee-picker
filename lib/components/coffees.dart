import 'package:coffee_picker/components/coffee_input.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/repositories/coffees.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Coffees extends ConsumerWidget {
  const Coffees({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    Future<List<Coffee>> coffees = getCoffees();

    return FutureBuilder(
      future: coffees,
      builder: (BuildContext context, AsyncSnapshot<List<Coffee>> snapshot) {
        return ScaffoldBuilder(
            body: ListView.builder(
              itemCount: snapshot.data?.length ?? 1,
              padding: const EdgeInsets.all(10),
              prototypeItem:
                  buildCard(theme, snapshot.data?.first.name ?? '', ''),
              itemBuilder: (context, index) {
                var item = snapshot.data?[index];
                return buildCard(theme, item?.name ?? '',
                    "Cost Per Oz: ${item?.costPerOz.toString() ?? ''}, Notes: ${item?.tastingNotes.join(',')}");
              },
            ),
            floatingActionButton: FloatingActionButton.small(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoffeeInput()),
                    ),
                child: const Icon(Icons.add)));
      },
    );
  }

  Card buildCard(ThemeData theme, String title, String subtitle) {
    return Card(
      color: theme.cardColor,
      child: InkWell(
        splashColor: theme.primaryColor,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [Text(title), Text(subtitle)],
        ),
      ),
    );
  }
}
