import 'package:coffee_picker/repositories/configs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigNotifier extends StateNotifier<Config> {
  ConfigNotifier.initial({config}) : super(config);
}

final configProvider = FutureProvider.autoDispose((ref) async {
  var config = await getConfig();
  return Config(
    title: config.title,
  );
});

final defaultConfig = Config(title: 'Coffee Picker');
