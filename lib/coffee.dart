import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'finance.dart';

const goldenRatio = 17;

double calculateCostPerLiquidWeight(double cost, double liquidWeight) {
  return cost / liquidWeight;
}

double coffeeLiquidPerCoffeeGrounds(double grounds,
    {groundToLiquidRatio = goldenRatio}) {
  return grounds * goldenRatio;
}

double costPerOz(double costOfGrounds, double weightOfGroundsInOz,
    {groundToLiquidRatio = goldenRatio}) {
  return calculateCostPerLiquidWeight(
      costOfGrounds,
      coffeeLiquidPerCoffeeGrounds(weightOfGroundsInOz,
          groundToLiquidRatio: groundToLiquidRatio));
}

double costPer12oz(double costOfGrounds, double weightOfGroundsInOz,
    {groundToLiquidRatio = goldenRatio}) {
  return costPerOz(costOfGrounds, weightOfGroundsInOz,
          groundToLiquidRatio: groundToLiquidRatio) *
      12;
}

double costOfDaily12ozPerYear(double costOfGrounds, double weightOfGroundsInOz,
    {groundToLiquidRatio = goldenRatio, daysInYear = 365}) {
  return costPer12oz(costOfGrounds, weightOfGroundsInOz,
          groundToLiquidRatio: groundToLiquidRatio) *
      daysInYear;
}

LineChartBarData starbucksStoreLineData(ThemeData themeData) {
  const costOf12oz = 2.65;
  var costPerYear = costOf12oz * 365;

  List<FlSpot> dataSpots = generateCompoundInterestData(costPerYear);

  return LineChartBarData(color: Colors.green, spots: dataSpots);
}

LineChartBarData dunkinLineData(ThemeData themeData) {
  const costPer30ozGrounds = 16.14;
  var costPerYear = costOfDaily12ozPerYear(costPer30ozGrounds, 30);

  List<FlSpot> dataSpots = generateCompoundInterestData(costPerYear);

  return LineChartBarData(
    color: Colors.orange,
    spots: dataSpots,
  );
}

LineChartBarData nightSwimLineData(ThemeData themeData) {
  const costPer12ozGrounds = 19.00;
  var costPerYear = costOfDaily12ozPerYear(costPer12ozGrounds, 12);

  List<FlSpot> dataSpots = generateCompoundInterestData(costPerYear);

  return LineChartBarData(
    color: const Color(0xff202a44),
    spots: dataSpots,
  );
}

LineChartBarData maxwellHouseLineData(ThemeData themeData) {
  const costPer30_6ozGrounds = 8.53;
  var costPerYear = costOfDaily12ozPerYear(costPer30_6ozGrounds, 30.6);

  List<FlSpot> dataSpots = generateCompoundInterestData(costPerYear);

  return LineChartBarData(
    color: Colors.blue,
    spots: dataSpots,
  );
}
