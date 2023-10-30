import 'package:coffee_picker/components/coffee.dart';
import 'package:coffee_picker/components/coffee_input.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/repositories/coffees.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Coffees extends ConsumerWidget {
  const Coffees({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<List<Coffee>> coffees = getCoffees();

    return FutureBuilder(
      future: coffees,
      builder: (BuildContext context, AsyncSnapshot<List<Coffee>> snapshot) {
        return ScaffoldBuilder(
            body: ListView.builder(
              itemCount: snapshot.data?.length ?? 1,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                Coffee? coffee = snapshot.data?[index];
                return coffee != null ?
                  buildCard(context, coffee) : null;
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

  Card buildCard(
      BuildContext context,
      Coffee coffee,
      ) {
    var theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CoffeeInfo(coffee: coffee)),
          );
        },
        splashColor: theme.primaryColor,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(coffee.name ?? ''),
            Text("Cost Per Oz: ${coffee.costPerOz.toString() ?? ''}, Notes: ${coffee.tastingNotes.join(',')}"),
          ],
        ),
      ),
    );
  }
}
