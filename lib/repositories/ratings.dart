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
      .get()
      .then((event) {
        return event.docs
            .map((e) => e.data())
            .toList();
      });
}

Future<List<Rating>> getCoffeeRatings(Coffee coffee) async {
  return await ratingsCollection
      .where('coffeeRef', isEqualTo: coffee.ref)
      .get()
      .then((event) {
    return event.docs
        .map((e) => e.data())
        .toList();
  });
}

Future<DocumentSnapshot<Rating>> addRating(Rating rating) async {
  return await ratingsCollection.add(rating).then((event) {
    if (kDebugMode) {
      print("${event.id} => ${event.path}");
    }
    return event.get();
  });
}

Rating fromJson(Map<String, dynamic>? json) {
  return Rating(
    userRef: json?['userRef'],
    userName: json?['userName'],
    coffeeRef: json?['coffeeRef'],
    coffeeName: json?['coffeeName'],
    rating: json?['rating'],
    review: json?['review'],
  );
}

Map<String, dynamic> toJson(Rating rating) {
  return {
    'userRef': rating.userRef,
    'userName': rating.userName,
    'coffeeRef': rating.coffeeRef,
    'coffeeName': rating.coffeeName,
    'rating': rating.rating,
    'review': rating.review,
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
  });

  final String userRef;
  final String userName;
  final String coffeeRef;
  final String coffeeName;
  final double rating;
  final String review;
}
