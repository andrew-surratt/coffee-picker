import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

final storage = FirebaseStorage.instance;
const publicFolder = 'public';

Future<Uint8List?> getStoredData(String imagePath, { bool optional = true }) async {
  try {
    return await storage.ref(publicFolder).child(imagePath).getData();
  } catch (e) {
    if (kDebugMode) {
      print({"Error getting storage data for path $imagePath", e});
    }
    if (optional) {
      return null;
    }
    return Future.error(e);
  }
}