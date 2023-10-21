import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'finance.dart';

// Coffee grounds to liquid ratio
const goldenRatio = 17;
const defaultDaysInYear = 365;
const defaultNumberOfOzPerDay = 12;

double calculateCostPerLiquidWeight(double cost, double liquidWeight) {
  return cost / liquidWeight;
}

double coffeeLiquidPerCoffeeGrounds(double grounds,
    {groundToLiquidRatio = goldenRatio}) {
  return grounds * goldenRatio;
}

double calculateCostPerOz(double costOfGrounds, double weightOfGroundsInOz,
    {groundToLiquidRatio = goldenRatio}) {
  return calculateCostPerLiquidWeight(
      costOfGrounds,
      coffeeLiquidPerCoffeeGrounds(weightOfGroundsInOz,
          groundToLiquidRatio: groundToLiquidRatio));
}

double costPer12oz(double costOfGrounds, double weightOfGroundsInOz,
    {groundToLiquidRatio = goldenRatio}) {
  var numberOfOz = 12;
  return calculateCostPerOz(costOfGrounds, weightOfGroundsInOz,
          groundToLiquidRatio: groundToLiquidRatio) *
      numberOfOz;
}

double costOfDaily12ozPerYear(double costOfGrounds, double weightOfGroundsInOz,
    {groundToLiquidRatio = goldenRatio, daysInYear = defaultDaysInYear}) {
  return costPer12oz(costOfGrounds, weightOfGroundsInOz,
          groundToLiquidRatio: groundToLiquidRatio) *
      daysInYear;
}

LineChartBarData createLineData(double costPerOz, Color color,
    {daysInYear = defaultDaysInYear, numberOfOz = defaultNumberOfOzPerDay}) {
  final costPerYear = calculateCostPerYearFromOz(costPerOz,
      numberOfOz: numberOfOz, daysInYear: daysInYear);

  List<FlSpot> dataSpots = generateCompoundInterestData(costPerYear);

  return LineChartBarData(color: color, spots: dataSpots);
}

double calculateCostPerYearFromOz(double costPerOz,
    {daysInYear = defaultDaysInYear, numberOfOz = defaultNumberOfOzPerDay}) {
  return calculateCostPerYear(
      calculateCostPerDay(costPerOz, numberOfOz: numberOfOz),
      daysInYear: daysInYear);
}

double calculateCostPerYear(double costPerDay,
        {daysInYear = defaultDaysInYear}) =>
    costPerDay * daysInYear;

double calculateCostPerDay(double costPerOz,
        {numberOfOz = defaultNumberOfOzPerDay}) =>
    costPerOz * numberOfOz;
