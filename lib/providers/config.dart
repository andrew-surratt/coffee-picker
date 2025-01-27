import 'package:coffee_picker/repositories/configs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigNotifier extends StateNotifier<Config> {
  ConfigNotifier.initial({config}) : super(config);
}

final configProvider = FutureProvider.autoDispose((ref) async {
  return await getConfig();
});

final defaultConfig = Config(
    title: 'Coffee Picker',
    isComparisonChartEnabled: false,
    defaultRoasterQuery: 'Counter Culture',
    defaultChartCoffeeNames: [
  'Maxwell Medium',
  'Starbucks (In Store)',
  'Counter Culture Hologram',
]);
