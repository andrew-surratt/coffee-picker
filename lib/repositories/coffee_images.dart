import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../utils/uuid.dart';

final storageRef = FirebaseStorage.instance.ref('coffee');

void uploadImage(File file, String uploadedPath) async {
  try {
    await storageRef.child(uploadedPath).putFile(file);
  } catch (e) {
    if (kDebugMode) {
      print({'Error uploading image file: ', e});
    }
    return Future.error(e);
  }
}

void uploadImageData(Uint8List data, String uploadedPath) async {
  try {
    await storageRef.child(uploadedPath).putData(data);
  } catch (e) {
    if (kDebugMode) {
      print({'Error uploading image data: ', e});
    }
    return Future.error(e);
  }
}

String createUploadPath(String ext) {
  return "${uuidV4()}/thumbnail.$ext";
}

Future<Uint8List?> downloadImage(String? downloadPath) async {
  try {
    if (downloadPath == null || downloadPath.isEmpty) {
      return null;
    }
    const oneMegabyte = 1024 * 1024;
    return await storageRef.child(downloadPath).getData(oneMegabyte);
  } catch (e) {
    if (kDebugMode) {
      print({'Error downloading image at path "$downloadPath": ', e});
    }
    return Future.error(e);
  }
}
