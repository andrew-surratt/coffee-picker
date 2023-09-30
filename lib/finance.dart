import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

double calculateCompoundInterest(
  double principal,
  double annualRate,
  double periods,
  double time,
) {
  return principal * pow(1 + (annualRate / periods), (periods * time));
}

double toPrecision(double value, {int precision = 2}) {
  return double.parse(value.toStringAsFixed(precision));
}

double calculateYearlyCompoundInterestSP500(double principal,
    {avgTotalYearlyReturn = 0.1}) {
  return toPrecision(
      calculateCompoundInterest(principal, avgTotalYearlyReturn, 12, 1));
}

List<FlSpot> generateCompoundInterestData(double valuePerInterval,
    {int points = 10, double interval = 1}) {
  var initialData = [const FlSpot(0, 0)];
  var xData = List<double>.generate(points, (i) => i + interval);
  return xData.fold<List<FlSpot>>(initialData, (value, element) {
    var lastOrNull = value.lastOrNull;
    if (lastOrNull == null) {
      value.add(FlSpot(
          element, calculateYearlyCompoundInterestSP500(valuePerInterval)));
    } else {
      value.add(FlSpot(
          element,
          calculateYearlyCompoundInterestSP500(
              lastOrNull.y + valuePerInterval)));
    }
    return value;
  });
}
