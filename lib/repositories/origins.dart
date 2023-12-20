import 'package:cloud_firestore/cloud_firestore.dart';

var originIndex = FirebaseFirestore.instance.collection('origins').doc('all');

Future<List<String>> getOriginIndex() async {
  return await originIndex
      .get()
      .then((value) => value.data()?.keys.toList() ?? []);
}

Future<void> upsertOriginIndex(String origin, {bool createDoc = false}) async {
  if (createDoc) {
    await originIndex.set({});
  }
  return await originIndex.update({origin: true});
}
