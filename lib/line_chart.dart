import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'coffee.dart';

Widget lineChart(BuildContext context) {
  var themeData = Theme.of(context);
  return LineChart(LineChartData(
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 20000,
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: themeData.scaffoldBackgroundColor.withOpacity(0.8),
          fitInsideHorizontally: true,
        ),
      ),
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
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
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
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      gridData: const FlGridData(show: false),
      lineBarsData: [
        starbucksLineData(themeData),
        dunkinLineData(themeData),
        nightSwimLineData(themeData),
      ]));
}

SideTitles getYTitles(BuildContext context) {
  const double interval = 1000;
  return getSideTitles(
    interval: interval,
    context: context,
    getTitleText: (double value, BuildContext context) => Text(
          (value ~/ interval).toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium
      )
  );
}

SideTitles getXTitles(BuildContext context) {
  return getSideTitles(
      context: context,
      getTitleText: (double value, BuildContext context) => Text(
          value.toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium
      )
  );
}

SideTitles getSideTitles({
  required BuildContext context,
  required Text Function(double, BuildContext) getTitleText,
  double interval = 1,
}) {
  return SideTitles(
    showTitles: true,
    reservedSize: 50,
    interval: interval,
    getTitlesWidget: (double value, TitleMeta meta) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: getTitleText(value, context),
      );
    });
}
