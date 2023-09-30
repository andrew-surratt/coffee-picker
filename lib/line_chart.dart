import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'coffee.dart';

Widget lineChart(BuildContext context) {
  var themeData = Theme.of(context);

  var coffeeData = [
    (name: 'Starbucks', data: starbucksStoreLineData(themeData)),
    (name: 'Dunkin', data: dunkinLineData(themeData)),
    (name: 'Night Swim', data: nightSwimLineData(themeData)),
    (name: 'Maxwell', data: maxwellHouseLineData(themeData)),
  ];
  var lineTouchData = LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 200,
        tooltipBgColor: themeData.scaffoldBackgroundColor.withOpacity(0.2),
        fitInsideHorizontally: true,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            return LineTooltipItem(
                "${coffeeData[touchedSpot.barIndex].name} \$${touchedSpot.y.toString()}",
                TextStyle(
                  color: touchedSpot.bar.gradient?.colors.first ??
                      touchedSpot.bar.color ??
                      Colors.blueGrey,
                ));
          }).toList();
        }),
  );
  return LineChart(LineChartData(
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 20000,
      lineTouchData: lineTouchData,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget: Text(
            'Time (years)',
            style: themeData.textTheme.labelMedium,
          ),
          sideTitles: getXTitles(context),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          axisNameSize: 30,
          axisNameWidget: Text(
            'Opportunity Cost Compared to Investing',
            style: themeData.textTheme.titleMedium,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            'Ending Balance (\$k)',
            style: themeData.textTheme.labelMedium,
          ),
          sideTitles: getYTitles(context),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: themeData.primaryColorDark),
          left: BorderSide(color: themeData.primaryColorDark),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      gridData: const FlGridData(show: false),
      lineBarsData: coffeeData.map((e) => e.data).toList()));
}

SideTitles getYTitles(BuildContext context) {
  const double interval = 1000;
  return getSideTitles(
      interval: interval,
      context: context,
      reservedSize: 30,
      getTitleText: (double value, BuildContext context) => Text(
          (value ~/ interval).toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium));
}

SideTitles getXTitles(BuildContext context) {
  return getSideTitles(
      context: context,
      reservedSize: 30,
      getTitleText: (double value, BuildContext context) => Text(
          value.toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium));
}

SideTitles getSideTitles({
  required BuildContext context,
  required Text Function(double, BuildContext) getTitleText,
  double interval = 1,
  double reservedSize = 50,
}) {
  return SideTitles(
      showTitles: true,
      reservedSize: reservedSize,
      interval: interval,
      getTitlesWidget: (double value, TitleMeta meta) {
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: getTitleText(value, context),
        );
      });
}
