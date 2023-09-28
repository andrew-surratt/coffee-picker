import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'finance.dart';

double calculateCostPerLiquidWeight(double cost, double liquidWeight) {
  return cost / liquidWeight;
}

double coffeeLiquidPerCoffeeGrounds(double grounds) {
  const goldenRatio = 17;
  return grounds * goldenRatio;
}


LineChartBarData starbucksLineData(ThemeData themeData) {
  const costOfStarbucks12oz = 2.65;
  var costOfStarbucksPerOz =
  calculateCostPerLiquidWeight(costOfStarbucks12oz, 12);
  var costOfStarbucksPerYear = costOfStarbucks12oz * 365;

  List<FlSpot> dataSpots = generateCompoundInterestData(costOfStarbucksPerYear);

  return LineChartBarData(color: Colors.green, spots: dataSpots);
}

LineChartBarData dunkinLineData(ThemeData themeData) {
  const costOfDunkinPer30ozGrounds = 16.14;
  var costOfDunkin12oz = calculateCostPerLiquidWeight(
      costOfDunkinPer30ozGrounds, coffeeLiquidPerCoffeeGrounds(30)) *
      12;
  var costOfDunkinPerYear = costOfDunkin12oz * 365;

  List<FlSpot> dataSpots = generateCompoundInterestData(costOfDunkinPerYear);

  return LineChartBarData(
    color: Colors.orange,
    spots: dataSpots,
  );
}

LineChartBarData nightSwimLineData(ThemeData themeData) {
  const costPer12ozGrounds = 19.00;
  var costOf12oz = calculateCostPerLiquidWeight(
    costPer12ozGrounds,
    coffeeLiquidPerCoffeeGrounds(12),
  ) * 12;
  var costPerYear = costOf12oz * 365;

  List<FlSpot> dataSpots = generateCompoundInterestData(costPerYear);

  return LineChartBarData(
    color: Colors.blue,
    spots: dataSpots,
  );
}
