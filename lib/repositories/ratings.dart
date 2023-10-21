import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

var ratingsCollection = FirebaseFirestore.instance.collection('ratings')
    .withConverter(fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
  return fromJson(snapshot.data());
}, toFirestore: (Rating rating, _) {
  return toJson(rating);
});

Future<List<Rating>> getRatings(String userRef) async {
  return await ratingsCollection.where('userRef', isEqualTo: userRef).get().then((event) {
    if (kDebugMode) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    }
    return event.docs.map((doc) => doc.data()).toList();
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
  return Rating(coffeeRef: json?['coffeeRef'], userRef: json?['userRef'], rating: json?['rating']);
}

Map<String, dynamic> toJson(Rating rating) {
  return {
    'coffeeRef': rating.coffeeRef,
    'userRef': rating.userRef,
    'rating': rating.rating,
  };
}

class Rating {
  Rating(
      {required this.coffeeRef, required this.userRef, required this.rating});

  final String coffeeRef;
  final String userRef;
  final double rating;
}

