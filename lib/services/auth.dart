import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

void useAuthState({void Function(User user)? onAuthChanged}) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      if (kDebugMode) {
        print(user.uid);
      }
      if (onAuthChanged != null) {
        onAuthChanged(user);
      }
    }
  });
}

Future<UserCredential> signup(String emailAddress, String password) async {
  try {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return Future.error(e);
  }
}

Future<UserCredential> login(String emailAddress, String password) async {
  try {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return Future.error(e);
  }
}
