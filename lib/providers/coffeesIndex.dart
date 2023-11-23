import 'package:coffee_picker/repositories/coffees.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final coffeeIndexProvider = FutureProvider.autoDispose((ref) async {
  var list = await getCoffeeIndex();
  if (kDebugMode) {
    print("coffeeIndexProvider $list");
  }
  return list;
});
