import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'coffees.dart';

var ratingsCollection = FirebaseFirestore.instance.collection('ratings');

Future<List<Rating>> getUserRatings(Coffee coffee, User? user) async {
  if (user == null) {
    return [];
  }
  return await ratingsCollection
      .doc(user.uid)
      .collection(coffee.ref)
      .withConverter(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
        return fromJson(snapshot.data());
      }, toFirestore: (Rating rating, _) {
        return toJson(rating);
      })
      .get()
      .then((event) {
        if (kDebugMode) {
          for (var doc in event.docs) {
            print("${doc.id} => ${doc.data()}");
          }
        }
        return event.docs.map((doc) => doc.data()).toList();
      });
}

Future<DocumentSnapshot<Rating>> addRating(
    Rating rating, Coffee coffee, User user) async {
  var userRatings = ratingsCollection
      .doc(user.uid)
      .collection(coffee.ref)
      .withConverter(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
    return fromJson(snapshot.data());
  }, toFirestore: (Rating rating, _) {
    return toJson(rating);
  });
  return await userRatings.add(rating).then((event) {
    if (kDebugMode) {
      print("${event.id} => ${event.path}");
    }
    return event.get();
  });
}

Rating fromJson(Map<String, dynamic>? json) {
  return Rating(
    rating: json?['rating'],
    review: json?['review'],
  );
}

Map<String, dynamic> toJson(Rating rating) {
  return {
    'rating': rating.rating,
    'review': rating.review,
  };
}

class Rating {
  Rating({required this.rating, required this.review});

  final double rating;
  final String review;
}
