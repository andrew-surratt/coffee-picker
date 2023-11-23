import 'package:coffee_picker/components/coffee.dart';
import 'package:coffee_picker/components/coffee_input.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/providers/coffeesIndex.dart';
import 'package:coffee_picker/repositories/coffees.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Coffees extends ConsumerStatefulWidget {
  const Coffees({super.key});

  @override
  ConsumerState<Coffees> createState() => _CoffeesState();
}

class _CoffeesState extends ConsumerState<Coffees> {
  Future<List<Coffee>> coffees = Future.value([]);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: coffees,
      builder: (BuildContext context, AsyncSnapshot<List<Coffee>> snapshot) {
        return ScaffoldBuilder(
            body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildSearchAnchor(),
                    ),
                  ),
                  Expanded(
                    child: buildResults(snapshot),
                  ),
                ]),
            floatingActionButton: FloatingActionButton.small(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoffeeInput()),
                    ),
                child: const Icon(Icons.add)));
      },
    );
  }

  ListView buildResults(AsyncSnapshot<List<Coffee>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data?.length ?? 0,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        Coffee? coffee = snapshot.data?[index];
        if (coffee == null) {
          return null;
        }
        return SizedBox(
          height: 70,
          child: buildCard(context, coffee),
        );
      },
    );
  }

  SearchAnchor buildSearchAnchor() {
    var coffeeIndex = ref.watch(coffeeIndexProvider);

    return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
      return SearchBar(
        controller: controller,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onTap: () {
          controller.openView();
        },
        onChanged: (_) {
          controller.openView();
        },
        onSubmitted: (String value) {
          coffees = getCoffee(value);
        },
        leading: const Icon(Icons.search),
      );
    }, suggestionsBuilder: (BuildContext context, SearchController controller) {
      return coffeeIndex.value?.map((e) => ListTile(
                title: Text(e),
                onTap: () {
                  setState(() {
                    controller.closeView(e);
                  });
                },
              )) ??
          [];
    });
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
            Text(
                "Cost Per Oz: ${coffee.costPerOz.toString() ?? ''}, Notes: ${coffee.tastingNotes.join(',')}"),
          ],
        ),
      ),
    );
  }
}
