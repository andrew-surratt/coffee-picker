import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

var coffeesCollection = FirebaseFirestore.instance
    .collection('coffees')
    .withConverter(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
  return fromJson(snapshot.data());
}, toFirestore: (CoffeeCreateReq coffee, _) {
  return toJson(coffee);
});

Future<List<Coffee>> getCoffees() async {
  return await coffeesCollection.get().then((event) {
    List<Coffee> coffees = event.docs.map((doc) {
      var data = doc.data();
      if (kDebugMode) {
        print("${doc.id} => $data");
      }
      return Coffee(
        ref: doc.reference.id,
        name: data.name,
        costPerOz: data.costPerOz,
        tastingNotes: data.tastingNotes,
        origins: data.origins,
      );
    }).toList();
    return coffees;
  });
}

Future<DocumentSnapshot<CoffeeCreateReq>> addCoffee(
    CoffeeCreateReq coffee) async {
  return await coffeesCollection.add(coffee).then((event) {
    if (kDebugMode) {
      print("${event.id} => ${event.path}");
    }
    return event.get();
  });
}

CoffeeCreateReq fromJson(Map<String, dynamic>? json) {
  return CoffeeCreateReq(
    name: json?['name'],
    costPerOz: json?['costPerOz'],
    tastingNotes: [...json?['tastingNotes']],
    origins: [...(json?['origins'] ?? [])]
        .map((e) =>
            CoffeeOrigin(origin: e['origin'], percentage: e['percentage']))
        .toList(),
  );
}

Map<String, dynamic> toJson(CoffeeCreateReq coffee) {
  return {
    'name': coffee.name,
    'costPerOz': coffee.costPerOz,
    'tastingNotes': coffee.tastingNotes,
    'origins': coffee.origins
        .map((e) => {
              'origin': e.origin,
              'percentage': e.percentage,
            })
        .toList(),
  };
}

class CoffeeOrigin {
  final String origin;
  final double percentage;

  CoffeeOrigin({
    required this.origin,
    required this.percentage,
  });
}

class CoffeeCreateReq {
  CoffeeCreateReq({
    required this.name,
    required this.costPerOz,
    required this.tastingNotes,
    required this.origins,
  });

  final String name;
  final double costPerOz;
  final List<String> tastingNotes;
  final List<CoffeeOrigin> origins;
}

class Coffee extends CoffeeCreateReq {
  Coffee({
    required name,
    required costPerOz,
    required tastingNotes,
    required origins,
    required this.ref,
  }) : super(
            name: name,
            costPerOz: costPerOz,
            tastingNotes: tastingNotes,
            origins: origins);

  final String ref;
}
