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

var coffeeIndexDoc =
    FirebaseFirestore.instance.collection('coffees').doc('all');

Future<List<CoffeeIndex>> getCoffeeIndex() async {
  return await coffeeIndexDoc.get().then((value) {
    if (kDebugMode) {
      print({"coffeeIndex", value.data()?.values});
    }
    return List.from(value
            .data()
            ?.values
            .map((e) {
              try {
                return CoffeeIndex(roaster: e?['roaster'], name: e?['name']);
              } catch (err) {
                if (kDebugMode) {
                  print({"Error parsing coffee index (skipping):", err});
                }
                return null;
              }
            })
            .where((e) => e != null)
            .toList() ??
        []);
  });
}

Future<void> upsertCoffeeIndex(String coffeeName, String roasterName,
    {bool createDoc = false}) async {
  if (createDoc) {
    await coffeeIndexDoc.set({});
  }

  return await coffeeIndexDoc.update({
    "$roasterName $coffeeName": {
      'roaster': roasterName,
      'name': coffeeName,
    }
  });
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

Future<Coffee> getCoffeeByRef(String coffeeRef) async {
  DocumentSnapshot<CoffeeCreateReq> doc =
      await coffeesCollection.doc(coffeeRef).get();
  return docToCoffee(doc);
}

Future<List<Coffee>> getCoffees(List<String> coffeeNames) async {
  return await coffeesCollection
      .where('name', whereIn: coffeeNames)
      .get()
      .then((event) {
    List<Coffee> coffees = event.docs.map(docToCoffee).toList();
    if (kDebugMode) {
      print({"[repositories.getCoffees()]", coffees});
    }
    return coffees;
  });
}

Future<List<Coffee>> getCoffeesByRoaster(String roasterName) async {
  return await coffeesCollection
      .where('roaster', isEqualTo: roasterName)
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
    roaster: data.roaster,
    name: data.name,
    costPerOz: data.costPerOz,
    tastingNotes: data.tastingNotes,
    usdaOrganic: data.usdaOrganic,
    fairTrade: data.fairTrade,
    origins: data.origins,
    thumbnailPath: data.thumbnailPath,
  );
}

Future<Coffee> addCoffee(CoffeeCreateReq coffee) async {
  return await coffeesCollection.add(coffee).then((event) {
    if (kDebugMode) {
      print("${event.id} => ${event.path}");
    }
    return event.get();
  }).then((event) {
    return docToCoffee(event);
  });
}

Future<void> updateCoffeeImage(String coffeeRef, String thumbnailPath) async {
  return await coffeesCollection.doc(coffeeRef).update({
    'thumbnailPath': thumbnailPath,
  });
}

CoffeeCreateReq fromJson(Map<String, dynamic>? json) {
  return CoffeeCreateReq(
    roaster: json?['roaster'] ?? '',
    name: json?['name'],
    costPerOz: json?['costPerOz'],
    tastingNotes: [...json?['tastingNotes']],
    usdaOrganic: json?['usdaOrganic'] ?? false,
    fairTrade: json?['fairTrade'] ?? false,
    thumbnailPath: json?['thumbnailPath'] ?? '',
    origins: [...(json?['origins'] ?? [])]
        .map((e) => CoffeeOrigin(
            origin: e['origin'], percentage: e['percentage'].toDouble()))
        .toList(),
  );
}

Map<String, dynamic> toJson(CoffeeCreateReq coffee) {
  return {
    'roaster': coffee.roaster,
    'name': coffee.name,
    'costPerOz': coffee.costPerOz,
    'tastingNotes': coffee.tastingNotes.map((e) => e.toLowerCase()).toList(),
    'usdaOrganic': coffee.usdaOrganic,
    'fairTrade': coffee.fairTrade,
    'thumbnailPath': coffee.thumbnailPath,
    'origins': coffee.origins
        .map((e) => {
              'origin': e.origin,
              'percentage': e.percentage,
            })
        .toList(),
  };
}

class CoffeeIndex {
  final String roaster;
  final String name;

  CoffeeIndex({required this.roaster, required this.name});
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
    required this.roaster,
    required this.name,
    required this.costPerOz,
    required this.tastingNotes,
    required this.origins,
    required this.usdaOrganic,
    required this.fairTrade,
    required this.thumbnailPath,
  });

  final String roaster;
  final String name;
  final double costPerOz;
  final List<String> tastingNotes;
  final List<CoffeeOrigin> origins;
  final bool usdaOrganic;
  final bool fairTrade;
  final String thumbnailPath;
}

class Coffee extends CoffeeCreateReq {
  Coffee({
    required super.roaster,
    required super.name,
    required super.costPerOz,
    required super.tastingNotes,
    required super.origins,
    required super.usdaOrganic,
    required super.fairTrade,
    required super.thumbnailPath,
    required this.ref,
  });

  final String ref;
}
