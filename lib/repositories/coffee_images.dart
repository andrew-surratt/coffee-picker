import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

final storageRef = FirebaseStorage.instance.ref('coffee');

void uploadImage(File file, String uploadedPath) async {
  try {
    await storageRef.child(uploadedPath).putFile(file);
  } catch (e) {
    if (kDebugMode) {
      print({'Error uploading image: ', e});
    }
    return Future.error(e);
  }
}

Future<Uint8List?> downloadImage(String downloadPath) async {
  try {
    const oneMegabyte = 1024 * 1024;
    return await storageRef.child(downloadPath).getData(oneMegabyte);
  } on FirebaseException catch (e) {
    if (kDebugMode) {
      print({'Error downloading image: ', e});
    }
    return Future.error(e);
  }
}