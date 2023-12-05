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

Future<List<String>> getCoffeeIndex() async {
  return await FirebaseFirestore.instance
      .collection('coffees')
      .doc('all')
      .get()
      .then((value) => value.data()?.keys.toList() ?? []);
}

void upsertCoffeeIndex(String coffeeName) async {
  return await FirebaseFirestore.instance
      .collection('coffees')
      .doc('all')
      .update({coffeeName: true});
}

Future<List<Coffee>> getCoffee(String coffeeName) async {
  return await coffeesCollection
      .where('name', isEqualTo: coffeeName)
      .get()
      .then((event) {
    List<Coffee> coffees = event.docs.map(docToCoffee).toList();
    return coffees;
  });
}

Future<List<Coffee>> getCoffees(List<String> coffeeNames) async {
  return await coffeesCollection
      .where('name', whereIn: coffeeNames)
      .get()
      .then((event) {
    List<Coffee> coffees = event.docs.map(docToCoffee).toList();
    return coffees;
  });
}

Coffee docToCoffee(doc) {
  var data = doc.data();
  if (kDebugMode) {
    print("${doc.id} => $data");
  }
  return Coffee(
    ref: doc.reference.id,
    name: data.name,
    costPerOz: data.costPerOz,
    tastingNotes: data.tastingNotes,
    usdaOrganic: data.usdaOrganic,
    fairTrade: data.fairTrade,
    origins: data.origins,
  );
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
    usdaOrganic: json?['usdaOrganic'] ?? false,
    fairTrade: json?['fairTrade'] ?? false,
    origins: [...(json?['origins'] ?? [])]
        .map((e) => CoffeeOrigin(
            origin: e['origin'], percentage: e['percentage'].toDouble()))
        .toList(),
  );
}

Map<String, dynamic> toJson(CoffeeCreateReq coffee) {
  return {
    'name': coffee.name,
    'costPerOz': coffee.costPerOz,
    'tastingNotes': coffee.tastingNotes.map((e) => e.toLowerCase()).toList(),
    'usdaOrganic': coffee.usdaOrganic,
    'fairTrade': coffee.fairTrade,
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
    required this.usdaOrganic,
    required this.fairTrade,
  });

  final String name;
  final double costPerOz;
  final List<String> tastingNotes;
  final List<CoffeeOrigin> origins;
  final bool usdaOrganic;
  final bool fairTrade;
}

class Coffee extends CoffeeCreateReq {
  Coffee({
    required name,
    required costPerOz,
    required tastingNotes,
    required origins,
    required usdaOrganic,
    required fairTrade,
    required this.ref,
  }) : super(
          name: name,
          costPerOz: costPerOz,
          tastingNotes: tastingNotes,
          origins: origins,
          usdaOrganic: usdaOrganic,
          fairTrade: fairTrade,
        );

  final String ref;
}
