import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/coffee.dart';

class CoffeesNotifier extends StateNotifier<List<Coffee>> {
  CoffeesNotifier() : super([]);

  CoffeesNotifier.initial({coffees}) : super(coffees);

  void addCoffee(Coffee coffee) {
    state = [...state, coffee];
  }

  void setCoffees(List<Coffee> coffees) {
    state = [...coffees];
  }
}

final coffeesProvider =
    StateNotifierProvider<CoffeesNotifier, List<Coffee>>((ref) {
  final starbucksPerOz = starbucksCostPerOz();
  final dunkinPerOz = dunkinCostPerOz();
  final nightSwimPerOz = nightSwimCostPerOz();
  final maxwellPerOz = maxwellHouseCostPerOz();

  return CoffeesNotifier.initial(coffees: [
    Coffee(
        name: 'Starbucks',
        costPerOz: starbucksPerOz,
        data: createLineData(starbucksPerOz, Colors.green)),
    Coffee(
        name: 'Dunkin',
        costPerOz: dunkinPerOz,
        data: createLineData(dunkinPerOz, Colors.orange)),
    Coffee(
        name: 'Maxwell',
        costPerOz: maxwellPerOz,
        data: createLineData(maxwellPerOz, Colors.blue)),
  ]);
});

class Coffee {
  Coffee(
      {required this.name, required this.costPerOz, required this.data, this.rating});

  final String name;
  final double costPerOz;
  final LineChartBarData data;
  double? rating;
}
