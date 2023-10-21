import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_picker/providers/config.dart';
import 'package:flutter/foundation.dart';

var configCollection = FirebaseFirestore.instance.collection('configs')
    .withConverter(fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
      var repoConfig = snapshot.data();
      return RepoConfig(type: repoConfig?['type'], title: repoConfig?['title']);
}, toFirestore: (RepoConfig repoConfig, _) {
  return {
    'type': repoConfig.type,
    'title': repoConfig.title,
  };
});

Future<Config> getConfig() async {
  return await configCollection.get().then((event) {
    if (kDebugMode) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    }
    RepoConfig? defaultRepoConfig = event.docs.where((QueryDocumentSnapshot<RepoConfig> element) {
      return element.data().type == 'default';
    }).firstOrNull?.data();
    return defaultRepoConfig ?? defaultConfig;
  });
}

class Config {
  final String title;

  Config({required this.title});
}

class RepoConfig extends Config {
  final String type;

  RepoConfig({required this.type, required super.title});
}

