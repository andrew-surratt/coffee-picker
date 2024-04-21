import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_picker/providers/config.dart';
import 'package:flutter/foundation.dart';

var configCollection = FirebaseFirestore.instance
    .collection('configs')
    .withConverter(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
  var repoConfig = snapshot.data();
  return RepoConfig(
      type: repoConfig?['type'],
      title: repoConfig?['title'] ?? defaultConfig.title,
      defaultChartCoffeeNames: repoConfig?['defaultChartCoffeeNames'] ?? defaultConfig.defaultChartCoffeeNames,
  );
}, toFirestore: (RepoConfig repoConfig, _) {
  return {
    'type': repoConfig.type,
    'title': repoConfig.title,
    'defaultChartCoffeeNames': repoConfig.defaultChartCoffeeNames,
  };
});

Future<Config> getConfig() async {
  return await configCollection.where('type', isEqualTo: 'default')
      .get().then((event) {

    RepoConfig? defaultRepoConfig = event.docs
        .map((e) {
          var data = e.data();
          if (kDebugMode) {
            print("${e.id} => $data");
          }
          return data;
        })
        .firstOrNull;
    return defaultRepoConfig ?? defaultConfig;
  });
}

class Config {
  final String title;
  final List<String> defaultChartCoffeeNames;

  Config({required this.title, required this.defaultChartCoffeeNames});
}

class RepoConfig extends Config {
  final String type;

  RepoConfig({required this.type, required super.title, required super.defaultChartCoffeeNames});
}
