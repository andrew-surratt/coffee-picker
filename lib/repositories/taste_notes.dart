import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

var tasteNotesDoc =
    FirebaseFirestore.instance.collection('taste_notes').doc('all');

Future<List<String>> getTasteNotes() async {
  DocumentSnapshot<Map<String, dynamic>> tasteNotesSnap =
      await tasteNotesDoc.get();
  List<String> tasteNotes = tasteNotesSnap.data()?.keys.toList() ?? [];
  if (kDebugMode) {
    print("getTasteNotes() $tasteNotes");
  }
  return tasteNotes;
}

void addTastingNote(String note) async {
  return await tasteNotesDoc.update({note.toLowerCase(): true});
}
