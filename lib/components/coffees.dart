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
                prototypeItem: ListTile(title: Text(snapshot.data?.first.name ?? '')),
                itemBuilder: (context, index) {
                  var item = snapshot.data?[index];
                  return ListTile(
                      title: Text(item?.name ?? ''),
                    subtitle: Text(item?.costPerOz.toString() ?? ''),
                  );
                },
            ),
            floatingActionButton: FloatingActionButton.small(
                onPressed: ()
                =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CoffeeInput()),
                    )
                , child: const Icon(Icons.add)
            )
        );
      },
    );
  }
}
