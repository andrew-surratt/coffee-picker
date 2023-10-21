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
    if (kDebugMode) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    }
    List<Coffee> coffees = event.docs.map((doc) =>
        Coffee(
          ref: doc.reference.id,
          name: doc.data().name,
          costPerOz: doc.data().costPerOz,
        )
    ).toList();
    return coffees;
  });
}

Future<DocumentSnapshot<CoffeeCreateReq>> addCoffee(CoffeeCreateReq coffee) async {
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
  );
}

Map<String, dynamic> toJson(CoffeeCreateReq coffee) {
  return {
    'name': coffee.name,
    'costPerOz': coffee.costPerOz,
  };
}

class CoffeeCreateReq {
  CoffeeCreateReq({required this.name, required this.costPerOz});

  final String name;
  final double costPerOz;
}

class Coffee extends CoffeeCreateReq {
  Coffee({
    required name,
    required costPerOz,
    required this.ref,
  }) : super(name: name, costPerOz: costPerOz);

  final String ref;
}
