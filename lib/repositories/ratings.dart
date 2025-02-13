import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'coffees.dart';

var ratingsCollection = FirebaseFirestore.instance
    .collection('ratings')
    .withConverter(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
  return fromJson(snapshot.data());
}, toFirestore: (Rating rating, _) {
  return toJson(rating);
});

Future<List<Rating>> getUserRatings(User? user) async {
  if (user == null) {
    return [];
  }
  return await ratingsCollection
      .where('userRef', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .get()
      .then((event) {
    return event.docs.map((e) => e.data()).toList();
  });
}

Future<List<CoffeeWithRating>> getUserRatingsForCoffees(
    User user, List<Coffee> coffees) async {
  return await ratingsCollection
      .where('userRef', isEqualTo: user.uid)
      .where('coffeeRef', whereIn: coffees.map((e) => e.ref))
      .orderBy('createdAt', descending: true)
      .get()
      .then((event) {
    var ratings = event.docs.map((r) => r.data()).toList();
    if (kDebugMode) {
      print({"[repositories.getUserRatingsForCoffees()]", ratings});
    }
    return List.from(coffees.map((c) {
      try {
        return CoffeeWithRating(
            coffee: c,
            rating: ratings.where((r) => r.coffeeRef == c.ref).firstOrNull);
      } catch (e) {
        if (kDebugMode) {
          print({'Error parsing coffee with rating info (skipping): ', e});
        }
        return null;
      }
    }).where((element) => element != null));
  });
}

Future<CoffeeWithRating> getUserRatingForCoffee(
    User user, Coffee coffee) async {
  return await ratingsCollection
      .where('userRef', isEqualTo: user.uid)
      .where('coffeeRef', isEqualTo: coffee.ref)
      .orderBy('createdAt', descending: true)
      .get()
      .then((event) {
    var ratings = event.docs.map((r) => r.data()).toList();
    return CoffeeWithRating(
        coffee: coffee,
        rating: ratings.where((r) => r.coffeeRef == coffee.ref).firstOrNull);
  });
}

Future<List<Rating>> getCoffeeRatings(Coffee coffee) async {
  return await ratingsCollection
      .where('coffeeRef', isEqualTo: coffee.ref)
      .orderBy('createdAt', descending: true)
      .get()
      .then((event) {
    return event.docs.map((QueryDocumentSnapshot<Rating> e) {
      Rating data = e.data();
      if (kDebugMode) {
        print(
            "Found coffee review for '${data.coffeeName}': '${data.userName}'");
      }
      return data;
    }).toList();
  });
}

Future<DocumentSnapshot<Rating>> addRating(Rating rating) async {
  if (kDebugMode) {
    print(
        "Adding rating for coffee '${rating.coffeeName}': user '${rating.userName}', ${toJson(rating)}");
  }
  return await ratingsCollection.add(rating).then((event) {
    if (kDebugMode) {
      print("${event.id} => ${event.path}");
    }
    return event.get();
  });
}

Rating fromJson(Map<String, dynamic>? json) {
  return Rating(
      userRef: json?['userRef'] ?? '',
      userName: json?['userName'] ?? '',
      coffeeRef: json?['coffeeRef'] ?? '',
      coffeeName: json?['coffeeName'] ?? '',
      rating: json?['rating'] ?? 0,
      review: json?['review'] ?? '',
      aromaValue: json?['aromaValue'] ?? 5,
      acidityValue: json?['acidityValue'] ?? 5,
      sweetnessValue: json?['sweetnessValue'] ?? 5,
      bodyValue: json?['bodyValue'] ?? 5,
      finishValue: json?['finishValue'] ?? 5,
      createdAt: json?['createdAt']);
}

Map<String, dynamic> toJson(Rating rating) {
  return {
    'userRef': rating.userRef,
    'userName': rating.userName,
    'coffeeRef': rating.coffeeRef,
    'coffeeName': rating.coffeeName,
    'rating': rating.rating,
    'review': rating.review,
    'aromaValue': rating.aromaValue,
    'acidityValue': rating.acidityValue,
    'sweetnessValue': rating.sweetnessValue,
    'bodyValue': rating.bodyValue,
    'finishValue': rating.finishValue,
    'createdAt': rating.createdAt,
  };
}

class Rating {
  Rating({
    required this.userRef,
    required this.userName,
    required this.coffeeRef,
    required this.coffeeName,
    required this.rating,
    required this.review,
    required this.aromaValue,
    required this.acidityValue,
    required this.sweetnessValue,
    required this.bodyValue,
    required this.finishValue,
    this.createdAt,
  });

  final String userRef;
  final String userName;
  final String coffeeRef;
  final String coffeeName;
  final double rating;
  final String review;
  final double aromaValue;
  final double acidityValue;
  final double sweetnessValue;
  final double bodyValue;
  final double finishValue;
  final Timestamp? createdAt;
}

class CoffeeWithRating {
  final Coffee coffee;
  final Rating? rating;

  CoffeeWithRating({required this.coffee, this.rating});
}
