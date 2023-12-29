import 'package:cloud_firestore/cloud_firestore.dart';

const String roastersCollection = 'roasters';
const String roastersIndexDocName = 'all';
var roastersIndex = FirebaseFirestore.instance
    .collection(roastersCollection)
    .doc(roastersIndexDocName);

Future<List<String>> getRoastersIndex() async {
  return await roastersIndex
      .get()
      .then((value) =>
  value
      .data()
      ?.keys
      .toList() ?? []);
}

Future<void> upsertRoastersIndex(String roasterName, {bool createDoc = false}) async {
  if (createDoc) {
    await roastersIndex.set({});
  }
  return await roastersIndex
      .update({roasterName: true});
}
